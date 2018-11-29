`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Martin, Michael
//                 Agnesina, Anthony
// 
// Create Date:    
// Design Name: 
// Module Name:    hw6_edge 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module hw6_edge (
    clk,
    en,
    pixel_in,
    pixel_in_valid,
    pixel_out,
    pixel_out_valid,
);

//Parameters
parameter IDLE = 0;
parameter ACTIVE = 1;
parameter END = 2;

//Inputs
input clk;
input en;
input [7:0] pixel_in;
input pixel_in_valid;

//Outputs
output reg [7:0] pixel_out;
output reg pixel_out_valid;

//Signals
reg en_reg = 0;
reg [7:0] pixel_in_reg = 0;
reg pixel_in_valid_reg = 0;
wire [7:0] pixel_out_sig;
reg pixel_out_valid_sig = 0;
reg en_shift = 0;
reg en_fifo_read = 0;
reg en_fifo_write = 0;
wire [7:0] fifo_1_out;
wire [7:0] fifo_2_out;
wire fifo_1_full;
wire fifo_2_full;
wire fifo_1_empty;
wire fifo_2_empty;
wire fifo_1_overflow;
wire fifo_2_overflow;
wire [7:0] z9;
wire [7:0] z8;
wire [7:0] z7;
wire [7:0] z6;
wire [7:0] z5;
wire [7:0] z4;
wire [7:0] z3;
wire [7:0] z2;
wire [7:0] z1;
wire [15:0] gx_1;
wire [15:0] gx_2;
wire [15:0] gy_1;
wire [15:0] gy_2;
wire [15:0] gx;
wire [15:0] gy;
wire [15:0] mag;
reg [15:0] threshold = 260;
reg [8:0] row = 0;
reg [8:0] row_sig;
reg [8:0] col = 0;
reg [8:0] col_sig;
reg [1:0] PS = 0;
reg [1:0] NS;
reg clr = 0;

//Components
simpleFIFO fifo_1 (
	.clk(clk),
    .reset(clr),
    .data_in(pixel_in_reg),
    .rd_ack_in(en_fifo_read),
    .wr_en_in(en_fifo_write),
    .data_out(fifo_1_out),
    .empty_out(fifo_1_empty),
    .full_out(fifo_1_full),
    .overflow_out(fifo_1_overflow)
);

simpleFIFO fifo_2 (
    .clk(clk),
    .reset(clr),
    .data_in(fifo_1_out),
    .rd_ack_in(en_fifo_read),
    .wr_en_in(en_fifo_write),
    .data_out(fifo_2_out),
    .empty_out(fifo_2_empty),
    .full_out(fifo_2_full),
    .overflow_out(fifo_2_overflow)
);

hw6_shift_reg shift_reg_1 (
    .clk(clk),
    .en(en_shift),
    .data(pixel_in_reg),
    .q1(z9),
    .q2(z8),
    .q3(z7)
);

hw6_shift_reg shift_reg_2 (
    .clk(clk),
    .en(en_shift),
    .data(fifo_1_out),
    .q1(z6),
    .q2(z5),
    .q3(z4)
);

hw6_shift_reg shift_reg_3 (
    .clk(clk),
    .en(en_shift),
    .data(fifo_2_out),
    .q1(z3),
    .q2(z2),
    .q3(z1)
);

//Sequential Logic
always @(posedge clk) begin
    //Register Inputs
    en_reg <= en;
    pixel_in_reg <= pixel_in;
    pixel_in_valid_reg <= pixel_in_valid;
    //Register Outputs
    pixel_out <= pixel_out_sig;
    pixel_out_valid <= pixel_out_valid_sig;
end

always @(posedge clk) begin
    PS <= NS;
end

always @(posedge clk) begin
    row <= row_sig;
    col <= col_sig;
end

//Combinational Logic
assign gx_1 = (z7 + (z8 << 1) + z9);
assign gx_2 = (z1 + (z2 << 1) + z3);
assign gx = (gx_1 > gx_2) ? (gx_1 - gx_2) : (gx_2 - gx_1);

assign gy_1 = (z3 + (z6 << 1) + z9);
assign gy_2 = (z1 + (z4 << 1) + z7);
assign gy = (gy_1 > gy_2) ? (gy_1 - gy_2) : (gy_2 - gy_1);

assign mag = gx + gy;

assign pixel_out_sig = (row == 0 ||
                        row == 511 ||
                        col == 0 ||
                        col == 511 ||
                        mag < threshold)
                        ? (0)
                        : (255);

always @(*) begin
    en_shift = 0;
    en_fifo_read = 0;
    en_fifo_write = 0;
    pixel_out_valid_sig = 0;
    clr = 0;
    row_sig = row;
    col_sig = col;
    NS = PS;
    case (PS)
        IDLE: begin
            if (en_reg && pixel_in_valid_reg) begin
                en_fifo_write = 1;
                NS = ACTIVE;
            end
            else begin
                clr = 1;
            end
        end
        ACTIVE: begin
            if (pixel_in_valid_reg) begin
                en_shift = 1;
                en_fifo_write = 1;
                if (fifo_1_full) begin
                    en_fifo_read = 1;
                    pixel_out_valid_sig = 1;
                    col_sig = col + 1;
                    if (col >= 511) begin
                        if (row >= 510) begin
                            NS = END;
                        end
                        row_sig = row + 1;
                    end
                end
            end
        end
        END: begin
            pixel_out_valid_sig = 1;
            col_sig = col + 1;
            if (col >= 511) begin
                if (row >= 511) begin
                    NS = IDLE;
                end
                row_sig = row + 1;
            end
        end
    endcase
end

endmodule