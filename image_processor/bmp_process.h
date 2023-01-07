#pragma once

#include "image.h"

#include <fstream>

Image ReadBMPFile(std::ifstream input);
void WriteBMPFile(std::ofstream output, const Image& image);
