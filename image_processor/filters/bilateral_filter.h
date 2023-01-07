#pragma once

#include "two_pass_blur_filter.h"

class BilateralFilter : public TwoPassBlurFilter {
public:
    BilateralFilter(const double& sigma_r, const double& sigma_s);

private:
    double sigma_r_;
    double sigma_s_;

protected:
    virtual double GetCoefficient(const Image& image, const size_t& y, const size_t& current_y, const size_t& x,
                                  const size_t& current_x) const;
};
