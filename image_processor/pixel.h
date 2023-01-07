#pragma once

#include <cstdint>

class Pixel {
public:
    Pixel() = default;
    Pixel(const uint8_t& red_component, const uint8_t& green_component, const uint8_t& blue_component);
    Pixel(const uint8_t& scaled_component);
    Pixel(const int& red_component, const int& green_component, const int& blue_component);
    Pixel(const double& red_component, const double& green_component, const double& blue_component);

    uint8_t red = 0;
    uint8_t green = 0;
    uint8_t blue = 0;
};
