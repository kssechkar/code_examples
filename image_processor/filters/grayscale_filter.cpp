#include "grayscale_filter.h"

void GrayscaleFilter::ApplyIterativeFilter(Image& image, const Image& original_image, const size_t& y,
                                           const size_t& x) const {
    image.GetPixel(y, x) = Pixel(original_image.GetPixel(y, x).red * 0.299 + original_image.GetPixel(y, x).green * 0.587 + original_image.GetPixel(y, x).blue * 0.114);
}
