# Implementation Notes

## What was actually implemented

The supplied implementation material verifies these stages:

- OpenCV-based image preprocessing on Raspberry Pi.
- Contour extraction and ordered boundary coordinates.
- Coordinate-pair generation.
- UART-oriented Raspberry Pi ↔ FPGA data path.
- Vivado/MicroBlaze integration.
- Custom AXI4-Lite distance-computation IP.
- FPGA computation of D4, D8, weighted Cityblock, and squared Euclidean distances.
- Directional classification from `dx` and `dy`.

## What is not claimed

The original lab report contains a theoretical section describing 8-directional chain codes and includes a chain-code stage in its flowchart. The repository deliberately does **not** claim that a complete chain-code sequence was implemented and verified.

This distinction matters for an accurate portfolio/GitHub description.

## Evidence in the project material

The Raspberry Pi code shows:
- `cv2.imread()`
- resize to `256 × 256`
- grayscale conversion
- Otsu thresholding
- `cv2.findContours()`
- extraction of contour points
- formation of serialized coordinate pairs.

The custom RTL shows:
- AXI4-Lite register interface
- coordinate input registers
- `dx`, `dy`
- D4
- D8
- weighted distance
- squared Euclidean distance
- direction mapping.

The MicroBlaze program demonstrates writing test coordinates to the IP and reading the computed results.
