#pragma once

#include "iterative_filter.h"

class GrayscaleFilter : public IterativeFilter {
public:
    void ApplyIterativeFilter(Image& image, const Image& original_image, const size_t& y,
                              const size_t& x) const override;
};
