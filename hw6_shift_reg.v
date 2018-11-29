`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Martin, Michael
//                 Agnesina, Anthony
// 
// Create Date:    
// Design Name: 
// Module Name:    hw6_shift_reg 
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
module hw6_shift_reg (
    clk,
    en,
    data,
    q1,
    q2,
    q3
);

//Inputs
input clk;
input en;
input [7:0] data;

//Outputs
output reg [7:0] q1;
output reg [7:0] q2;
output reg [7:0] q3;

//Sequential Logic
always @(posedge clk) begin
    if (en) begin
        q1 <= data;
        q2 <= q1;
        q3 <= q2;
    end
end

endmodule