# Architecture

## System-level flow

**Raspberry Pi 4B**
- Image input
- Resize to 256×256
- Grayscale conversion
- Otsu thresholding
- External contour extraction
- Ordered boundary coordinates
- Coordinate-pair generation

↓

**UART**

↓

**Spartan-7 FPGA**
- UART / MicroBlaze integration
- AXI4-Lite custom distance IP
- `dx`, `dy`
- D4 / Manhattan
- D8 / Chessboard
- Weighted Cityblock
- Squared Euclidean
- 8-way directional movement classification

↓

**UART / output path**

↓

**Raspberry Pi**
- Receive/display feature data

## Direction mapping

The RTL uses the sign of the coordinate differences to assign values 0–7 to the eight possible non-zero movement directions. This is a directional feature, not a complete contour chain-code sequence.

## AXI register map

| Offset | Register | Function |
|---:|---|---|
| 0x00 | `slv_reg0` | x1 |
| 0x04 | `slv_reg1` | y1 |
| 0x08 | `slv_reg2` | x2 |
| 0x0C | `slv_reg3` | y2 |
| 0x10 | `out_dx` | x2 − x1 |
| 0x14 | `out_dy` | y2 − y1 |
| 0x18 | `out_D4` | Manhattan distance |
| 0x1C | `out_D8` | Chessboard distance |
| 0x20 | `direction` | 8-way direction code |
| 0x24 | `out_DE` | Squared Euclidean distance |
