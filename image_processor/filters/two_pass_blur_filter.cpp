#include "two_pass_blur_filter.h"

namespace {

const double EPS = 1e-6;

}  // namespace

Image TwoPassBlurFilter::GetBaseImage(const Image& original_image) const {
    return Image(original_image, original_image.GetHeight(), original_image.GetWidth());
}

Image TwoPassBlurFilter::Apply(const Image& original_image) const {
    auto horizontal_blur_image = GetBaseImage(original_image);
    for (size_t y = 0; y < original_image.GetHeight(); ++y) {
        for (size_t x = 0; x < original_image.GetWidth(); ++x) {
            ApplyHorizontalBlur(horizontal_blur_image, original_image, y, x);
        }
    }

    auto image = GetBaseImage(horizontal_blur_image);
    for (size_t y = 0; y < horizontal_blur_image.GetHeight(); ++y) {
        for (size_t x = 0; x < horizontal_blur_image.GetWidth(); ++x) {
            ApplyVerticalBlur(image, horizontal_blur_image, y, x);
        }
    }

    return image;
}

void TwoPassBlurFilter::ApplyHorizontalBlur(Image& image, const Image& original_image, const size_t& y,
                                            const size_t& x) const {
    int red_component = 0;
    int green_component = 0;
    int blue_component = 0;
    double normalization_term = 0;
    for (size_t current_x = 0; current_x < image.GetWidth(); ++current_x) {
        double coefficient = GetCoefficient(original_image, y, y, x, current_x);
        if (coefficient > EPS) {
            normalization_term += coefficient;
            red_component += original_image.GetPixel(y, current_x).red * coefficient;
            green_component += original_image.GetPixel(y, current_x).green * coefficient;
            blue_component += original_image.GetPixel(y, current_x).blue * coefficient;
        }
    }

    image.GetPixel(y, x) = Pixel(red_component / normalization_term, green_component / normalization_term,
                                 blue_component / normalization_term);
}

void TwoPassBlurFilter::ApplyVerticalBlur(Image& image, const Image& original_image, const size_t& y,
                                          const size_t& x) const {
    int red_component = 0;
    int green_component = 0;
    int blue_component = 0;
    double normalization_term = 0;
    for (size_t current_y = 0; current_y < image.GetHeight(); ++current_y) {
        double coefficient = GetCoefficient(original_image, y, current_y, x, x);
        if (coefficient > EPS) {
            normalization_term += coefficient;
            red_component += original_image.GetPixel(current_y, x).red * coefficient;
            green_component += original_image.GetPixel(current_y, x).green * coefficient;
            blue_component += original_image.GetPixel(current_y, x).blue * coefficient;
        }
    }

    image.GetPixel(y, x) = Pixel(red_component / normalization_term, green_component / normalization_term,
                                 blue_component / normalization_term);
}
