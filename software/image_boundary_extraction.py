import cv2
import numpy as np
import serial
import time

# --------------------------------------------------
# LOAD IMAGE
# --------------------------------------------------
image = cv2.imread("square2.jpg")

if image is None:
    print("Error: Image not found!")
    raise SystemExit

image = cv2.resize(image, (256, 256))

# --------------------------------------------------
# PREPROCESSING
# --------------------------------------------------
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

_, binary = cv2.threshold(
    gray,
    0,
    255,
    cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU
)

cv2.imshow("Binary Image", binary)

# --------------------------------------------------
# BOUNDARY EXTRACTION
# --------------------------------------------------
contours, _ = cv2.findContours(
    binary,
    cv2.RETR_EXTERNAL,
    cv2.CHAIN_APPROX_NONE
)

if len(contours) == 0:
    print("No contours found!")
    raise SystemExit

# Select the largest detected object
contour = max(contours, key=cv2.contourArea)

# Convert contour to (x, y) coordinate pairs
points = contour.reshape(-1, 2)

print("Total boundary points:", len(points))

# --------------------------------------------------
# DRAW CONTOUR
# --------------------------------------------------
contour_image = image.copy()
cv2.drawContours(contour_image, [contour], -1, (0, 0, 255), 2)

cv2.imshow("Contour Image", contour_image)

# --------------------------------------------------
# SEND DATA TO FPGA
# --------------------------------------------------
# Configure the serial port according to the actual
# Raspberry Pi ↔ FPGA UART connection.
#
# ser = serial.Serial("/dev/serial0", 115200, timeout=1)

print("Sending data to FPGA...")

step = 10

for i in range(0, len(points) - 1, step):
    x1, y1 = points[i]
    x2, y2 = points[i + 1]

    data = f"S,{x1},{y1},{x2},{y2},E\n"
    print(data.strip())

    # Uncomment when the UART interface is configured:
    # ser.write(data.encode())
    # time.sleep(0.001)

# --------------------------------------------------
# WAIT & CLOSE WINDOWS
# --------------------------------------------------
cv2.waitKey(0)
cv2.destroyAllWindows()

# ser.close()
