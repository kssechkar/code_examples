#include "edge_detection_filter.h"
#include "grayscale_filter.h"

#include <algorithm>

EdgeDetectionFilter::EdgeDetectionFilter(const double& threshold)
    : threshold_(static_cast<uint8_t>(std::clamp(static_cast<int>(255 * threshold), 0, 255))) {
}

Image EdgeDetectionFilter::GetBaseImage(const Image& original_image) const {
    return GrayscaleFilter().Apply(Image(original_image, original_image.GetHeight(), original_image.GetWidth()));
}

void EdgeDetectionFilter::ApplyMatrixFilter(Image& image, const Image& base_image, const size_t& y,
                                            const size_t& x) const {
    Pixel modified_pixel =
        ModifyPixel(filter_matrix_, base_image.GetPixelsAround(y, x, filter_matrix_.size()), filter_matrix_.size());

    if (modified_pixel.red > threshold_) {
        modified_pixel.red = modified_pixel.green = modified_pixel.blue = 255;
    } else {
        modified_pixel.red = modified_pixel.green = modified_pixel.blue = 0;
    }

    image.GetPixel(y, x) = modified_pixel;
}
