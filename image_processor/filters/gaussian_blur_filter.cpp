#include "gaussian_blur_filter.h"

#include <cmath>

namespace {

size_t GetCoordinateDifference(const size_t& y, const size_t& current_y, const size_t& x, const size_t& current_x) {
    return std::max(std::abs(static_cast<int>(y) - static_cast<int>(current_y)),
                    std::abs(static_cast<int>(x) - static_cast<int>(current_x)));
}

double GetGaussianCoefficient(const size_t& parameter, const double& sigma) {
    return (std::pow(M_E, ((std::pow(parameter / sigma, 2)) / (-2))));
}

}  // namespace

GaussianBlurFilter::GaussianBlurFilter(const double& sigma) : sigma_(sigma) {
}

double GaussianBlurFilter::GetCoefficient(const Image& image, const size_t& y, const size_t& current_y, const size_t& x,
                                          const size_t& current_x) const {
    size_t coordinate_difference = GetCoordinateDifference(y, current_y, x, current_x);
    if (coordinate_difference > std::abs(3.4 * sigma_)) {
        return 0;
    } else {
        return GetGaussianCoefficient(coordinate_difference, sigma_);
    }
}
