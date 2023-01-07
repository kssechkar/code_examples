#pragma once

#include "../image.h"

class Filter {
public:
    virtual Image Apply(const Image& original_image) const = 0;
    virtual ~Filter() = default;
};
