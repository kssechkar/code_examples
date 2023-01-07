#include "binary_data_process.h"

void SkipNBytes(std::ifstream& input, const size_t& n) {
    for (size_t i = 0; i < n; ++i) {
        ReadBytes<uint8_t>(input);
    }
}
