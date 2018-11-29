`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Martin, Michael
//                 Agnesina, Anthony
// 
// Create Date:    
// Design Name: 
// Module Name:    hw6_top 
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
module hw6_top(
    clk,
    sel_operation,
    R_in,
    G_in,
    B_in,
    HS_in,
    VS_in,
    pixel_out,
    pixel_valid_out,
    R_out,
    G_out,
    B_out,
    HS_out,
    VS_out
);
    
//Inputs
input clk;
input sel_operation;
input [7:0] R_in, G_in, B_in;
input HS_in, VS_in;

//Outputs
output reg [7:0] pixel_out;
output reg pixel_valid_out;
output [7:0] R_out, G_out, B_out;
output VS_out, HS_out;

//Signals
wire [7:0] pixel_in;
wire pixel_valid_in;
wire [7:0] pixel_transpose;
wire pixel_transpose_valid;
wire [7:0] pixel_edge;
wire pixel_edge_valid;

//Components
hw6_vga2pixel vga2pixel (
    .clk(clk),
    .R(R_in),
    .G(G_in),
    .B(B_in),
    .HS(HS_in),
    .VS(VS_in),
    .out_pixel(pixel_in),
    .out_pixel_valid(pixel_valid_in)
);

hw6_transpose transpose (
    .clk(clk),
    .en(sel_operation),
    .pixel_in(pixel_in),
    .pixel_in_valid(pixel_valid_in),
    .pixel_out(pixel_transpose),
    .pixel_out_valid(pixel_transpose_valid)
);

hw6_edge edgedetect (
    .clk(clk),
    .en(~sel_operation),
    .pixel_in(pixel_in),
    .pixel_in_valid(pixel_valid_in),
    .pixel_out(pixel_edge),
    .pixel_out_valid(pixel_edge_valid)
);

hw6_pixel2vga pixel2vga (
    .clk(clk),
    .pixel_in(pixel_out),
    .pixel_in_valid(pixel_valid_out),
    .R(R_out),
    .G(G_out),
    .B(B_out),
    .HS(HS_out),
    .VS(VS_out)
);

//Combinational Logic
always @(*) begin
    if (sel_operation) begin
        pixel_out = pixel_transpose;
        pixel_valid_out = pixel_transpose_valid;
    end
    else begin
        pixel_out = pixel_edge;
        pixel_valid_out = pixel_edge_valid;
    end
end

endmodule
