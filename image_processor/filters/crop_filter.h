#pragma once

#include "abstract_filter.h"

class CropFilter : public Filter {
public:
    CropFilter(const size_t width, const size_t height);
    Image Apply(const Image& original_image) const override;

private:
    size_t height_;
    size_t width_;
};
