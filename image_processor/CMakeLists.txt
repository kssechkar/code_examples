cmake_minimum_required(VERSION 3.17)
project(image_processor)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")

add_executable(image_processor
        binary_data_process.cpp
        bmp_process.cpp
        controller/controller.cpp
        filters/bilateral_filter.cpp
        filters/crop_filter.cpp
        filters/edge_detection_filter.cpp
        filters/gaussian_blur_filter.cpp
        filters/grayscale_filter.cpp
        filters/iterative_filter.cpp
        filters/matrix_filter.cpp
        filters/negative_filter.cpp
        filters/sharpening_filter.cpp
        filters/two_pass_blur_filter.cpp
        image.cpp
        image_processor.cpp
        pixel.cpp)
