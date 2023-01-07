#include "matrix_filter.h"

Pixel MatrixFilter::ModifyPixel(const FilterMatrix& filter_matrix, const BitmapData& data,
                                const size_t& offset_limit) {
    int red_component = 0;
    int green_component = 0;
    int blue_component = 0;

    for (size_t y = 0; y < offset_limit; ++y) {
        for (size_t x = 0; x < offset_limit; ++x) {
            red_component += (filter_matrix[y][x] * data[y][x].red);
            green_component += (filter_matrix[y][x] * data[y][x].green);
            blue_component += (filter_matrix[y][x] * data[y][x].blue);
        }
    }

    return Pixel(red_component, green_component, blue_component);
}

void MatrixFilter::ApplyIterativeFilter(Image& image, const Image& original_image, const size_t& y, const size_t& x) const {
    ApplyMatrixFilter(image, original_image, y, x);
}
