#include "crop_filter.h"

CropFilter::CropFilter(const size_t width, const size_t height) : height_(height), width_(width) {
}

Image CropFilter::Apply(const Image& original_image) const {
    return Image(original_image, height_, width_);
}
