#pragma once

#include "abstract_filter.h"

class TwoPassBlurFilter : public Filter {
public:
    Image GetBaseImage(const Image& original_image) const;
    Image Apply(const Image& original_image) const override;

protected:
    virtual double GetCoefficient(const Image& image, const size_t& y, const size_t& current_y, const size_t& x,
                                  const size_t& current_x) const = 0;

    void ApplyHorizontalBlur(Image& image, const Image& original_image, const size_t& y, const size_t& x) const;
    void ApplyVerticalBlur(Image& image, const Image& original_image, const size_t& y, const size_t& x) const;
};
