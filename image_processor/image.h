#pragma once

#include "pixel.h"

#include <vector>

using BitmapData = std::vector<std::vector<Pixel>>;

class Image {
public:
    Image(const BitmapData& data);
    Image(const Image& other, const size_t& height, const size_t& width);

    const size_t GetHeight() const;
    const size_t GetWidth() const;

    Pixel& GetPixel(const size_t& y, const size_t& x);
    const Pixel& GetPixel(const size_t& y, const size_t& x) const;
    BitmapData GetPixelsAround(const size_t& y, const size_t& x, const size_t& offset_limit) const;

private:
    BitmapData data_;
    size_t height_;
    size_t width_;
};
