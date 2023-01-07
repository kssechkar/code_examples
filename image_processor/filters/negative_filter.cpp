#include "negative_filter.h"

void NegativeFilter::ApplyIterativeFilter(Image& image, const Image& original_image, const size_t& y,
                                          const size_t& x) const {
    image.GetPixel(y, x) = Pixel(255 - original_image.GetPixel(y, x).red, 255 - original_image.GetPixel(y, x).green,
                                 255 - original_image.GetPixel(y, x).blue);
}
