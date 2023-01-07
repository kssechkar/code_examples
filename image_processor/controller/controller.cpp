#include "controller.h"

#include "../filters/bilateral_filter.h"
#include "../filters/crop_filter.h"
#include "../filters/edge_detection_filter.h"
#include "../filters/gaussian_blur_filter.h"
#include "../filters/grayscale_filter.h"
#include "../filters/negative_filter.h"
#include "../filters/sharpening_filter.h"

#include <exception>
#include <fstream>
#include <functional>
#include <unordered_map>

namespace {

void PushBilateralFilter(std::vector<Filter*>& filters, const int& argc, char**& argv, size_t& argument_position) {
    if (argument_position + 2 < argc) {
        try {
            filters.push_back(
                new BilateralFilter(std::stod(argv[argument_position + 1]), std::stod(argv[argument_position + 2])));
            argument_position += 2;
        } catch (const std::exception) {
        }
    }
}

void PushCropFilter(std::vector<Filter*>& filters, const int& argc, char**& argv, size_t& argument_position) {
    if (argument_position + 2 < argc) {
        try {
            filters.push_back(
                new CropFilter(std::stoull(argv[argument_position + 1]), std::stoull(argv[argument_position + 2])));
            argument_position += 2;
        } catch (const std::exception) {
        }
    }
}

void PushEdgeDetectionFilter(std::vector<Filter*>& filters, const int& argc, char**& argv, size_t& argument_position) {
    if (argument_position + 1 < argc) {
        try {
            filters.push_back(new EdgeDetectionFilter(std::stod(argv[argument_position + 1])));
            ++argument_position;
        } catch (const std::exception) {
        }
    }
}

void PushGaussianBlurFilter(std::vector<Filter*>& filters, const int& argc, char**& argv, size_t& argument_position) {
    if (argument_position + 1 < argc) {
        try {
            filters.push_back(new GaussianBlurFilter(std::stod(argv[argument_position + 1])));
            ++argument_position;
        } catch (const std::exception) {
        }
    }
}

void PushGrayscaleFilter(std::vector<Filter*>& filters, const int& argc, char**& argv, size_t& argument_position) {
    filters.push_back(new GrayscaleFilter());
}

void PushNegativeFilter(std::vector<Filter*>& filters, const int& argc, char**& argv, size_t& argument_position) {
    filters.push_back(new NegativeFilter());
}

void PushSharpeningFilter(std::vector<Filter*>& filters, const int& argc, char**& argv, size_t& argument_position) {
    filters.push_back(new SharpeningFilter());
}

}  // namespace

Controller::Controller(int argc, char** argv) {
    if (argc >= 2) {
        input_file_ = std::string(argv[1]);
    }

    if (argc >= 3) {
        output_file_ = std::string(argv[2]);
    }

    if (GetInputStream().good() && GetOutputStream().good()) {
        static std::unordered_map<std::string, std::function<void(std::vector<Filter*>& filters, const int& argc,
                                                                  char**& argv, size_t& argument_position)>>
            filters_map = {{"-bilateral", PushBilateralFilter},
                           {"-crop", PushCropFilter},
                           {"-edge", PushEdgeDetectionFilter},
                           {"-blur", PushGaussianBlurFilter},
                           {"-gs", PushGrayscaleFilter},
                           {"-neg", PushNegativeFilter},
                           {"-sharp", PushSharpeningFilter}};

        for (size_t argument_position = 3; argument_position < argc; ++argument_position) {
            if (filters_map.contains(argv[argument_position])) {
                filters_map[argv[argument_position]](filters_, argc, argv, argument_position);
            }
        }
    }
}

Controller::~Controller() {
    for (const auto& filter : filters_) {
        delete filter;
    }
}

std::ifstream Controller::GetInputStream() const {
    return std::ifstream(input_file_, std::ios::binary);
}

std::ofstream Controller::GetOutputStream() const {
    return std::ofstream(output_file_, std::ios::binary);
}

Image Controller::ApplyFilters(Image image) {
    for (const auto& filter : filters_) {
        image = filter->Apply(image);
    }
    return image;
}
