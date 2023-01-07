#include "image.h"

namespace {

void CopyBitmapData(const BitmapData& data, const size_t& height, const size_t& width, BitmapData& result_data) {
    result_data = BitmapData(height, std::vector<Pixel>(width));

    for (size_t y = 0; y < height; ++y) {
        for (size_t x = 0; x < width; ++x) {
            result_data[y][x] = data[y][x];
        }
    }
}

size_t GetValidCoordinate(size_t coordinate, size_t coordinate_offset, size_t limit) {
    return std::clamp((static_cast<int>(coordinate) + static_cast<int>(coordinate_offset)), 0,
                      static_cast<int>(limit));
}

}  // namespace

Image::Image(const BitmapData& data) : data_(data) {
    height_ = data_.size();
    width_ = data_.front().size();
}

Image::Image(const Image& other, const size_t& height, const size_t& width) {
    height_ = std::min(other.GetHeight(), height);
    width_ = std::min(other.GetWidth(), width);
    CopyBitmapData(other.data_, height_, width_, data_);
}

const size_t Image::GetHeight() const {
    return height_;
}

const size_t Image::GetWidth() const {
    return width_;
}

Pixel& Image::GetPixel(const size_t& y, const size_t& x) {
    return data_[y][x];
}

const Pixel& Image::GetPixel(const size_t& y, const size_t& x) const {
    return data_[y][x];
}

BitmapData Image::GetPixelsAround(const size_t& y, const size_t& x, const size_t& offset_limit) const {
    auto data = BitmapData(offset_limit, std::vector<Pixel>(offset_limit, Pixel()));

    for (size_t y_offset = 0; y_offset < offset_limit; ++y_offset) {
        for (size_t x_offset = 0; x_offset < offset_limit; ++x_offset) {
            data[y_offset][x_offset] =
                data_[GetValidCoordinate(y, y_offset, height_ - 1)][GetValidCoordinate(x, x_offset, width_ - 1)];
        }
    }

    return data;
}
