#pragma once

#include "abstract_filter.h"

class IterativeFilter : public Filter {
public:
    virtual Image GetBaseImage(const Image& original_image) const;
    virtual Image Apply(const Image& original_image) const override;
    virtual void ApplyIterativeFilter(Image& image, const Image& original_image, const size_t& y,
                                      const size_t& x) const = 0;
};
