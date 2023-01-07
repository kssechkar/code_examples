#include "bilateral_filter.h"

#include <cmath>

namespace {

size_t GetCoordinateDifference(const size_t& y, const size_t& current_y, const size_t& x, const size_t& current_x) {
    return std::max(std::abs(static_cast<int>(y) - static_cast<int>(current_y)),
                    std::abs(static_cast<int>(x) - static_cast<int>(current_x)));
}

size_t GetColorDifference(const Pixel& pixel1, const Pixel& pixel2) {
    return std::abs(static_cast<int>(pixel1.red) - static_cast<int>(pixel2.red)) +
           std::abs(static_cast<int>(pixel1.green) - static_cast<int>(pixel2.green)) +
           std::abs(static_cast<int>(pixel1.blue) - static_cast<int>(pixel2.blue));
}

double GetGaussianCoefficient(const size_t& parameter, const double& sigma) {
    return (std::pow(M_E, ((std::pow(parameter / sigma, 2)) / (-2))));
}

}  // namespace

BilateralFilter::BilateralFilter(const double& sigma_r, const double& sigma_s) : sigma_r_(sigma_r), sigma_s_(sigma_s) {
}

double BilateralFilter::GetCoefficient(const Image& image, const size_t& y, const size_t& current_y, const size_t& x,
                                       const size_t& current_x) const {
    size_t coordinate_difference = GetCoordinateDifference(y, current_y, x, current_x);
    size_t color_difference = GetColorDifference(image.GetPixel(y, x), image.GetPixel(current_y, current_x));

    if (coordinate_difference > std::abs(1.9 * sigma_r_) || color_difference > std::abs(1.9 * sigma_s_)) {
        return 0;
    } else {
        return GetGaussianCoefficient(coordinate_difference, sigma_r_) *
               GetGaussianCoefficient(color_difference, sigma_s_);
    }
}
