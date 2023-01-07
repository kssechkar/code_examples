#pragma once

#include "../filters/abstract_filter.h"

#include <string>

class Controller {
public:
    Controller(int argc, char** argv);
    ~Controller();

    std::ifstream GetInputStream() const;
    std::ofstream GetOutputStream() const;

    Image ApplyFilters(Image image);
private:
    std::string input_file_;
    std::string output_file_;
    std::vector<Filter*> filters_;
};
