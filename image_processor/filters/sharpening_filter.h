#pragma once

#include "matrix_filter.h"

class SharpeningFilter : public MatrixFilter {
public:
    void ApplyMatrixFilter(Image& image, const Image& original_image, const size_t& y, const size_t& x) const override;

private:
    FilterMatrix filter_matrix_ = {{0, -1, 0}, {-1, 5, -1}, {0, -1, 0}};
};
