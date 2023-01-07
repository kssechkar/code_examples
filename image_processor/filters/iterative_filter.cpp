#include "iterative_filter.h"

Image IterativeFilter::GetBaseImage(const Image& original_image) const {
    return Image(original_image, original_image.GetHeight(), original_image.GetWidth());
}

Image IterativeFilter::Apply(const Image& original_image) const {
    auto image = GetBaseImage(original_image);

    for (size_t y = 0; y < original_image.GetHeight(); ++y) {
        for (size_t x = 0; x < original_image.GetWidth(); ++x) {
            ApplyIterativeFilter(image, original_image, y, x);
        }
    }

    return image;
}
