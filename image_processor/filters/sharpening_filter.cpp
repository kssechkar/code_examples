#include "sharpening_filter.h"

void SharpeningFilter::ApplyMatrixFilter(Image& image, const Image& original_image, const size_t& y,
                                         const size_t& x) const {
    image.GetPixel(y, x) =
        ModifyPixel(filter_matrix_, original_image.GetPixelsAround(y, x, filter_matrix_.size()), filter_matrix_.size());
}
