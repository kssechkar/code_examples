## Usage

`{program name} {inout file path} {output file path}
[-{filter name 1} [filter parameter 1] [filter parameter 1] ...]
[-{filter name 2} [filter parameter 2] [filter parameter 2] ...]

### Example
`./image_processor input.bmp /tmp/output.bmp -crop 800 600 -gs -blur 0.5`

### Available filters:

#### Crop (-crop width height)

#### Grayscale (-gs)

#### Negative (-neg)

#### Sharpening (-sharp)

#### Edge Detection (-edge threshold)

#### Gaussian Blur (-blur sigma)
