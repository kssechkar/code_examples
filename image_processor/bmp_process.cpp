#include "binary_data_process.h"
#include "bmp_process.h"

namespace {

struct BMPHeader {
    uint16_t id;
    uint32_t file_size;
    uint16_t specification1;
    uint16_t specification2;
    uint32_t pixel_data_offset;
};

struct DIBHeader {
    uint32_t dib_header_size;
    uint32_t width;
    uint32_t height;
    uint16_t color_planes;
    uint16_t bits_per_pixel;
    uint32_t pixel_compression;
    uint32_t bitmap_data_size;
    uint32_t resolution1;
    uint32_t resolution2;
    uint32_t palette_size;
    uint32_t important_colors;
};

struct Header {
    BMPHeader bmp_header;
    DIBHeader dib_header;
};

size_t CalculatePadding(const size_t& width) {
    size_t padding = 0;
    for (size_t possible_padding = 0; possible_padding < 4; ++possible_padding) {
        if ((width * 3 + possible_padding) % 4 == 0) {
            padding = possible_padding;
        }
    }
    return padding;
}

BMPHeader ReadBMPHeader(std::ifstream& input) {
    BMPHeader bmp_header;

    bmp_header.id = ReadBytes<uint16_t>(input);
    bmp_header.file_size = ReadBytes<uint32_t>(input);
    bmp_header.specification1 = ReadBytes<uint16_t>(input);
    bmp_header.specification2 = ReadBytes<uint16_t>(input);
    bmp_header.pixel_data_offset = ReadBytes<uint32_t>(input);

    return bmp_header;
}

DIBHeader ReadDIBHeader(std::ifstream& input) {
    DIBHeader dib_header;

    dib_header.dib_header_size = ReadBytes<uint32_t>(input);
    dib_header.width = ReadBytes<uint32_t>(input);
    dib_header.height = ReadBytes<uint32_t>(input);
    dib_header.color_planes = ReadBytes<uint16_t>(input);
    dib_header.bits_per_pixel = ReadBytes<uint16_t>(input);
    dib_header.pixel_compression = ReadBytes<uint32_t>(input);
    dib_header.bitmap_data_size = ReadBytes<uint32_t>(input);
    dib_header.resolution1 = ReadBytes<uint32_t>(input);
    dib_header.resolution2 = ReadBytes<uint32_t>(input);
    dib_header.palette_size = ReadBytes<uint32_t>(input);
    dib_header.important_colors = ReadBytes<uint32_t>(input);

    return dib_header;
}

Header ReadHeader(std::ifstream& input) {
    Header header;
    header.bmp_header = ReadBMPHeader(input);
    header.dib_header = ReadDIBHeader(input);
    return header;
}

Pixel ReadPixel(std::ifstream& input) {
    Pixel pixel;
    pixel.blue = ReadBytes<uint8_t>(input);
    pixel.green = ReadBytes<uint8_t>(input);
    pixel.red = ReadBytes<uint8_t>(input);
    return pixel;
}

BitmapData ReadBitmapData(std::ifstream& input, const size_t& height, const size_t& width) {
    BitmapData data(height, std::vector<Pixel>(width));

    size_t padding = CalculatePadding(width);
    for (size_t y = height; y >= 1; --y) {

        for (size_t x = 0; x < width; ++x) {
            data[y - 1][x] = ReadPixel(input);
        }

        SkipNBytes(input, padding);
    }
    return data;
}

BMPHeader CreateValidHBMPHeader(const size_t& height, const size_t& width) {
    BMPHeader bmp_header;
    bmp_header.id = 19778;
    bmp_header.file_size = 54 + height * (width * 3 + CalculatePadding(width));
    bmp_header.specification1 = 0;
    bmp_header.specification2 = 0;
    bmp_header.pixel_data_offset = 54;

    return bmp_header;
}

DIBHeader CreateValidDIBHeader(const size_t& height, const size_t& width) {
    DIBHeader dib_header;
    dib_header.dib_header_size = 40;
    dib_header.width = width;
    dib_header.height = height;
    dib_header.color_planes = 1;
    dib_header.bits_per_pixel = 24;
    dib_header.pixel_compression = 0;
    dib_header.bitmap_data_size = height * (width * 3 + CalculatePadding(width));
    dib_header.resolution1 = 0;
    dib_header.resolution2 = 0;
    dib_header.palette_size = 0;
    dib_header.important_colors = 0;

    return dib_header;
}

void WriteBMPHeader(std::ofstream& output, const size_t& height, const size_t& width) {
    BMPHeader bmp_header = CreateValidHBMPHeader(height, width);

    WriteBytes<uint16_t>(output, bmp_header.id);
    WriteBytes<uint32_t>(output, bmp_header.file_size);
    WriteBytes<uint16_t>(output, bmp_header.specification1);
    WriteBytes<uint16_t>(output, bmp_header.specification2);
    WriteBytes<uint32_t>(output, bmp_header.pixel_data_offset);
}

void WriteDIBHeader(std::ofstream& output, const size_t& height, const size_t& width) {
    DIBHeader dib_header = CreateValidDIBHeader(height, width);

    WriteBytes<uint32_t>(output, dib_header.dib_header_size);
    WriteBytes<uint32_t>(output, dib_header.width);
    WriteBytes<uint32_t>(output, dib_header.height);
    WriteBytes<uint16_t>(output, dib_header.color_planes);
    WriteBytes<uint16_t>(output, dib_header.bits_per_pixel);
    WriteBytes<uint32_t>(output, dib_header.pixel_compression);
    WriteBytes<uint32_t>(output, dib_header.bitmap_data_size);
    WriteBytes<uint32_t>(output, dib_header.resolution1);
    WriteBytes<uint32_t>(output, dib_header.resolution2);
    WriteBytes<uint32_t>(output, dib_header.palette_size);
    WriteBytes<uint32_t>(output, dib_header.important_colors);
}

void WriteHeader(std::ofstream& output, const Image& image, const size_t& height, const size_t& width) {
    WriteBMPHeader(output, height, width);
    WriteDIBHeader(output, height, width);
}

void WritePixel(std::ofstream& output, const Pixel& pixel) {
    WriteBytes<uint8_t>(output, pixel.blue);
    WriteBytes<uint8_t>(output, pixel.green);
    WriteBytes<uint8_t>(output, pixel.red);
}

void WritePadding(std::ofstream& output, const size_t& padding) {
    for (size_t i = 0; i < padding; ++i) {
        WriteBytes<uint8_t>(output, 0);
    }
}

void WriteBitmapData(std::ofstream& output, const Image& image, const size_t& height, const size_t& width) {
    size_t padding = CalculatePadding(width);

    for (size_t y = height; y >= 1; --y) {
        for (size_t x = 0; x < width; ++x) {
            WritePixel(output, image.GetPixel(y - 1, x));
        }
        WritePadding(output, padding);
    }
}

}  // namespace

Image ReadBMPFile(std::ifstream input) {
    Header header = ReadHeader(input);
    size_t height = header.dib_header.height;
    size_t width = header.dib_header.width;
    return Image(ReadBitmapData(input, height, width));
}

void WriteBMPFile(std::ofstream output, const Image& image) {
    size_t height = image.GetHeight();
    size_t width = image.GetWidth();
    WriteHeader(output, image, height, width);
    WriteBitmapData(output, image, height, width);
}
