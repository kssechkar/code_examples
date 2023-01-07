#pragma once

#include "two_pass_blur_filter.h"

class GaussianBlurFilter : public TwoPassBlurFilter {
public:
    GaussianBlurFilter(const double& sigma);

protected:
    virtual double GetCoefficient(const Image& image, const size_t& y, const size_t& current_y, const size_t& x,
                                  const size_t& current_x) const;

private:
    double sigma_;
};
