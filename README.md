# Hardware–Software Co-Design for Shape Feature Extraction

A Raspberry Pi–FPGA co-design project for extracting **boundary-based geometric features** from binary images and accelerating distance computation on a Spartan-7 FPGA.

> **Implementation note:** The academic report contains theory on 8-directional chain codes, but a complete chain-code feature extractor was **not implemented as a standalone feature in the final system**. This repository therefore does **not** claim chain-code generation as a completed implementation. The implemented system focuses on boundary-coordinate extraction, directional movement classification, and FPGA-based distance computation.

## Overview

The Raspberry Pi performs the image-processing stages:

1. Load and resize the image to `256 × 256`.
2. Convert the image to grayscale.
3. Apply Otsu thresholding to obtain a binary image.
4. Detect the external contour using OpenCV.
5. Extract ordered boundary coordinates.
6. Form consecutive coordinate pairs.
7. Transfer coordinate data toward the FPGA over UART.

The FPGA side contains a custom AXI4-Lite distance-computation IP integrated with a MicroBlaze-based Vivado design. The hardware computes:

- `dx`, `dy`
- D4 / Manhattan distance
- D8 / Chessboard distance
- Weighted Cityblock distance
- Squared Euclidean distance

A directional value (0–7) is also derived from the sign of `dx` and `dy`. This is a directional movement classification and should not be presented as a complete chain-code implementation.

## Hardware

- Raspberry Pi 4B
- Spartan-7 FPGA board
- UART connection between Raspberry Pi and FPGA
- Vivado + MicroBlaze
- Custom AXI4-Lite peripheral for distance computation

## Implemented Architecture

```text
                 RASPBERRY PI 4B
        ┌─────────────────────────────┐
        │ Image Input                 │
        │      ↓                      │
        │ Grayscale + Thresholding    │
        │      ↓                      │
        │ Contour Extraction          │
        │      ↓                      │
        │ Boundary Coordinates        │
        │      ↓                      │
        │ Coordinate Pair Formation   │
        └─────────────┬───────────────┘
                      │ UART
                      ↓
              ┌─────────────────┐
              │ Spartan-7 FPGA  │
              │                 │
              │ UART / MicroBlaze
              │       ↓         │
              │ AXI4-Lite IP    │
              │       ↓         │
              │ dx, dy          │
              │ D4, D8          │
              │ Weighted        │
              │ Squared Euclid. │
              │ Direction       │
              └────────┬────────┘
                       │
                       │ UART
                       ↓
                 Raspberry Pi
                 Output Display
```

## Repository Structure

```text
shape-feature-extraction-fpga/
├── README.md
├── software/
│   └── raspberry_pi/
│       ├── image_boundary_extraction.py
│       └── requirements.txt
├── fpga/
│   ├── custom_ip/
│   │   └── distance_ip_v1_0_S00_AXI.v
│   └── microblaze/
│       └── distance_test.c
├── vivado/
│   └── README.md
├── docs/
│   ├── architecture.md
│   ├── implementation-notes.md
│   └── images/
└── LICENSE
```

## Distance Features

For two boundary points `(x1, y1)` and `(x2, y2)`:

- `dx = x2 - x1`
- `dy = y2 - y1`
- D4 = `|dx| + |dy|`
- D8 = `max(|dx|, |dy|)`
- Weighted Cityblock = hardware implementation uses `|dx| + 2|dy|`
- Squared Euclidean = `dx² + dy²`

The squared form is used instead of an actual square-root Euclidean calculation to avoid the additional hardware cost of a square-root operation.

## Direction Classification

The implemented RTL maps the signs of `dx` and `dy` to eight directional movement classes:

```text
        3   2   1
        4   ·   0
        5   6   7
```

This is included as a **directional feature**, not as a claim that a full chain-code sequence was implemented.

## Raspberry Pi Processing

The Python implementation uses:

- OpenCV
- NumPy
- PySerial

The current processing code extracts the largest external contour and forms coordinate pairs for transfer.

## FPGA Custom IP

The custom peripheral exposes memory-mapped input registers for:

```text
x1
y1
x2
y2
```

and output registers for:

```text
dx
dy
D4
D8
direction
squared Euclidean
```

The IP uses an AXI4-Lite slave interface and is intended to be controlled by MicroBlaze.

## MicroBlaze Software

The MicroBlaze test program writes coordinate values to the custom IP using `Xil_Out32()` and reads the computed values using `Xil_In32()`.

The readable direction name and adaptive software-side weighted calculation are included in the test program.

## Important Scope Clarification

The supplied academic report is titled around chain-code and distance feature extraction and includes chain-code theory, an 8-direction diagram, and a flowchart containing a chain-code stage.

However, those report elements should be treated as **background/theoretical material** unless independently implemented and verified.

For this repository, the completed implementation is represented as:

**Image preprocessing → boundary extraction → coordinate transfer → directional movement classification + distance computation → feature output**

rather than:

**Image preprocessing → complete chain-code generation**

## Evidence

The project material includes:

- Raspberry Pi + Spartan-7 hardware setup
- Raspberry Pi terminal output showing boundary-point transmission
- Python/OpenCV contour-processing code
- Vivado/MicroBlaze block design
- Custom AXI4-Lite distance IP
- MicroBlaze software for reading and displaying feature values

Screenshots and diagrams can be placed under `docs/images/`.

## Academic Reference

The original lab report contains additional theoretical material on chain codes and distance metrics. The repository intentionally separates that theory from the verified implementation so that the project documentation remains technically accurate.
