#pragma once

#include "matrix_filter.h"

class EdgeDetectionFilter : public MatrixFilter {
public:
    EdgeDetectionFilter(const double& threshold);
    Image GetBaseImage(const Image& image) const override;
    void ApplyMatrixFilter(Image& image, const Image& original_image, const size_t& y, const size_t& x) const override;

private:
    uint8_t threshold_;
    FilterMatrix filter_matrix_ = {{0, -1, 0}, {-1, 4, -1}, {0, -1, 0}};
};
