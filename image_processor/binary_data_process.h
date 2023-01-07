#pragma once

#include <fstream>

template <typename T>
void WriteBytes(std::ofstream& output, T bytes) {
    output.write(reinterpret_cast<char*>(&bytes), sizeof(T));
}

template <typename T>
T ReadBytes(std::ifstream& input) {
    T bytes;
    input.read(reinterpret_cast<char*>(&bytes), sizeof(T));
    return bytes;
}

void SkipNBytes(std::ifstream& input, const size_t& n);
