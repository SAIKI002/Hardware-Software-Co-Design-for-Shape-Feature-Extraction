#include <stdio.h>
#include <stdlib.h>
#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"

#define DIST_BASE XPAR_DISTANCE_IP_V1_0_0_BASEADDR

static const char* get_direction(int dx, int dy)
{
    if (dx > 0 && dy == 0) return "EAST";
    if (dx > 0 && dy > 0) return "NORTH-EAST";
    if (dx == 0 && dy > 0) return "NORTH";
    if (dx < 0 && dy > 0) return "NORTH-WEST";
    if (dx < 0 && dy == 0) return "WEST";
    if (dx < 0 && dy < 0) return "SOUTH-WEST";
    if (dx == 0 && dy < 0) return "SOUTH";
    if (dx > 0 && dy < 0) return "SOUTH-EAST";
    return "NO MOVEMENT";
}

/*
 * Software-side adaptive weighted Cityblock calculation used
 * in the supplied MicroBlaze test program.
 */
static int compute_weighted_cityblock(int dx, int dy)
{
    int abs_dx = abs(dx);
    int abs_dy = abs(dy);

    if (abs_dx > abs_dy)
        return (2 * abs_dx) + abs_dy;
    else if (abs_dy > abs_dx)
        return abs_dx + (2 * abs_dy);
    else
        return abs_dx + abs_dy;
}

int main(void)
{
    xil_printf("\r\n=====================================\r\n");
    xil_printf(" FEATURE EXTRACTION (FINAL OUTPUT) \r\n");
    xil_printf("=====================================\r\n");

    /* Example input pair */
    int x1 = 10, y1 = 20;
    int x2 = 30, y2 = 40;

    /* Write input coordinates to AXI registers */
    Xil_Out32(DIST_BASE + 0,  x1);
    Xil_Out32(DIST_BASE + 4,  y1);
    Xil_Out32(DIST_BASE + 8,  x2);
    Xil_Out32(DIST_BASE + 12, y2);

    for (volatile int i = 0; i < 1000000; i++);

    /* Read hardware results */
    int dx = Xil_In32(DIST_BASE + 16);
    int dy = Xil_In32(DIST_BASE + 20);
    int D4 = Xil_In32(DIST_BASE + 24);
    int D8 = Xil_In32(DIST_BASE + 28);
    int DE = Xil_In32(DIST_BASE + 36);

    int DW = compute_weighted_cityblock(dx, dy);
    const char* direction = get_direction(dx, dy);

    xil_printf("\r\n----------- FINAL OUTPUT -----------\r\n");
    xil_printf("Direction : %s\r\n", direction);
    xil_printf("D4 (Manhattan) : %d\r\n", D4);
    xil_printf("D8 (Chessboard) : %d\r\n", D8);
    xil_printf("Weighted Cityblock : %d\r\n", DW);
    xil_printf("Squared Euclidean : %d\r\n", DE);
    xil_printf("------------------------------------\r\n");

    while (1);
    return 0;
}
