#pragma once

#include "iterative_filter.h"

using FilterMatrix = std::vector<std::vector<int>>;

class MatrixFilter : public IterativeFilter {
public:
    static Pixel ModifyPixel(const FilterMatrix& filter_matrix, const BitmapData& data,
                             const size_t& offset_limit);

    void ApplyIterativeFilter(Image& image, const Image& original_image, const size_t& y,
                              const size_t& x) const override;

    virtual void ApplyMatrixFilter(Image& image, const Image& original_image, const size_t& y,
                                   const size_t& x) const = 0;
};
