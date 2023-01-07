#include "pixel.h"

#include <algorithm>

Pixel::Pixel(const uint8_t& red_component, const uint8_t& green_component, const uint8_t& blue_component)
    : red(red_component), green(green_component), blue(blue_component) {
}

Pixel::Pixel(const uint8_t& scaled_component) : red(scaled_component), green(scaled_component), blue(scaled_component) {
}

Pixel::Pixel(const int& red_component, const int& green_component, const int& blue_component) {
    red = static_cast<uint8_t>(std::clamp(red_component, 0, 255));
    green = static_cast<uint8_t>(std::clamp(green_component, 0, 255));
    blue = static_cast<uint8_t>(std::clamp(blue_component, 0, 255));
}

Pixel::Pixel(const double& red_component, const double& green_component, const double& blue_component) {
    red = static_cast<uint8_t>(std::clamp(static_cast<int>(red_component), 0, 255));
    green = static_cast<uint8_t>(std::clamp(static_cast<int>(green_component), 0, 255));
    blue = static_cast<uint8_t>(std::clamp(static_cast<int>(blue_component), 0, 255));
}
