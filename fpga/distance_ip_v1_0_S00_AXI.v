`timescale 1 ns / 1 ps

module distance_ip_v1_0_S00_AXI #
(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 6
)
(
    input wire S_AXI_ACLK,
    input wire S_AXI_ARESETN,

    input wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input wire [2:0] S_AXI_AWPROT,
    input wire S_AXI_AWVALID,
    output wire S_AXI_AWREADY,

    input wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input wire S_AXI_WVALID,
    output wire S_AXI_WREADY,

    output wire [1:0] S_AXI_BRESP,
    output wire S_AXI_BVALID,
    input wire S_AXI_BREADY,

    input wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input wire [2:0] S_AXI_ARPROT,
    input wire S_AXI_ARVALID,
    output wire S_AXI_ARREADY,

    output wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output wire [1:0] S_AXI_RRESP,
    output wire S_AXI_RVALID,
    input wire S_AXI_RREADY
);

reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
reg axi_awready;
reg axi_wready;
reg [1:0] axi_bresp;
reg axi_bvalid;
reg [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;
reg axi_arready;
reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;
reg [1:0] axi_rresp;
reg axi_rvalid;

localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
localparam integer OPT_MEM_ADDR_BITS = 3;

reg [31:0] slv_reg0;
reg [31:0] slv_reg1;
reg [31:0] slv_reg2;
reg [31:0] slv_reg3;

reg [31:0] out_dx;
reg [31:0] out_dy;
reg [31:0] out_D4;
reg [31:0] out_D8;
reg [31:0] out_DW;
reg [31:0] out_DE;
reg [2:0] direction;

reg aw_en;
wire slv_reg_wren;
wire slv_reg_rden;
reg [31:0] reg_data_out;

integer byte_index;

assign S_AXI_AWREADY = axi_awready;
assign S_AXI_WREADY  = axi_wready;
assign S_AXI_BRESP   = axi_bresp;
assign S_AXI_BVALID  = axi_bvalid;
assign S_AXI_ARREADY = axi_arready;
assign S_AXI_RDATA   = axi_rdata;
assign S_AXI_RRESP   = axi_rresp;
assign S_AXI_RVALID  = axi_rvalid;

always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_awready <= 1'b0;
        aw_en <= 1'b1;
    end else begin
        if (!axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
            axi_awready <= 1'b1;
            aw_en <= 1'b0;
        end else if (S_AXI_BREADY && axi_bvalid) begin
            aw_en <= 1'b1;
            axi_awready <= 1'b0;
        end else begin
            axi_awready <= 1'b0;
        end
    end
end

always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN)
        axi_awaddr <= 0;
    else if (!axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
        axi_awaddr <= S_AXI_AWADDR;
end

always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN)
        axi_wready <= 1'b0;
    else if (!axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en)
        axi_wready <= 1'b1;
    else
        axi_wready <= 1'b0;
end

assign slv_reg_wren =
    axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        slv_reg0 <= 0;
        slv_reg1 <= 0;
        slv_reg2 <= 0;
        slv_reg3 <= 0;
    end else if (slv_reg_wren) begin
        case (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
            4'h0: slv_reg0 <= S_AXI_WDATA;
            4'h1: slv_reg1 <= S_AXI_WDATA;
            4'h2: slv_reg2 <= S_AXI_WDATA;
            4'h3: slv_reg3 <= S_AXI_WDATA;
            default: ;
        endcase
    end
end

always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_bvalid <= 1'b0;
        axi_bresp <= 2'b00;
    end else if (axi_awready && S_AXI_AWVALID &&
                 !axi_bvalid && axi_wready && S_AXI_WVALID) begin
        axi_bvalid <= 1'b1;
        axi_bresp <= 2'b00;
    end else if (S_AXI_BREADY && axi_bvalid) begin
        axi_bvalid <= 1'b0;
    end
end

always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_arready <= 1'b0;
        axi_araddr <= 0;
    end else if (!axi_arready && S_AXI_ARVALID) begin
        axi_arready <= 1'b1;
        axi_araddr <= S_AXI_ARADDR;
    end else begin
        axi_arready <= 1'b0;
    end
end

always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        axi_rvalid <= 1'b0;
        axi_rresp <= 2'b00;
    end else if (axi_arready && S_AXI_ARVALID && !axi_rvalid) begin
        axi_rvalid <= 1'b1;
        axi_rresp <= 2'b00;
    end else if (axi_rvalid && S_AXI_RREADY) begin
        axi_rvalid <= 1'b0;
    end
end

assign slv_reg_rden = axi_arready && S_AXI_ARVALID && !axi_rvalid;

always @(*) begin
    case (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
        4'h0: reg_data_out = slv_reg0;
        4'h1: reg_data_out = slv_reg1;
        4'h2: reg_data_out = slv_reg2;
        4'h3: reg_data_out = slv_reg3;
        4'h4: reg_data_out = out_dx;
        4'h5: reg_data_out = out_dy;
        4'h6: reg_data_out = out_D4;
        4'h7: reg_data_out = out_D8;
        4'h8: reg_data_out = {29'd0, direction};
        4'h9: reg_data_out = out_DE;
        default: reg_data_out = 32'd0;
    endcase
end

always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN)
        axi_rdata <= 0;
    else if (slv_reg_rden)
        axi_rdata <= reg_data_out;
end

wire signed [31:0] x1 = slv_reg0;
wire signed [31:0] y1 = slv_reg1;
wire signed [31:0] x2 = slv_reg2;
wire signed [31:0] y2 = slv_reg3;

wire signed [31:0] dx = x2 - x1;
wire signed [31:0] dy = y2 - y1;

wire [31:0] abs_dx = (dx < 0) ? -dx : dx;
wire [31:0] abs_dy = (dy < 0) ? -dy : dy;

wire [31:0] D4 = abs_dx + abs_dy;
wire [31:0] D8 = (abs_dx > abs_dy) ? abs_dx : abs_dy;
wire [31:0] DW = abs_dx + (2 * abs_dy);
wire [31:0] DE = (dx * dx) + (dy * dy);

always @(*) begin
    if (dx > 0 && dy == 0)
        direction = 3'd0;
    else if (dx > 0 && dy > 0)
        direction = 3'd1;
    else if (dx == 0 && dy > 0)
        direction = 3'd2;
    else if (dx < 0 && dy > 0)
        direction = 3'd3;
    else if (dx < 0 && dy == 0)
        direction = 3'd4;
    else if (dx < 0 && dy < 0)
        direction = 3'd5;
    else if (dx == 0 && dy < 0)
        direction = 3'd6;
    else if (dx > 0 && dy < 0)
        direction = 3'd7;
    else
        direction = 3'd0;
end

always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        out_dx <= 0;
        out_dy <= 0;
        out_D4 <= 0;
        out_D8 <= 0;
        out_DW <= 0;
        out_DE <= 0;
    end else begin
        out_dx <= dx;
        out_dy <= dy;
        out_D4 <= D4;
        out_D8 <= D8;
        out_DW <= DW;
        out_DE <= DE;
    end
end

endmodule
