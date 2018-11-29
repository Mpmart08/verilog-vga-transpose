`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Martin, Michael
//                 Agnesina, Anthony
// 
// Create Date:    
// Design Name: 
// Module Name:    hw6_ram 
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
module hw6_ram (
    clk,
    en,
    we,
    addr,
    di,
    do
);

input clk;
input we;
input en;
input [17:0] addr;
input [7:0] di;
output [7:0] do;
reg [7:0] RAM [262143:0];
reg [7:0] do;

always @(posedge clk)
begin
    if (en)
    begin
        if (we)
            RAM[addr]<=di;
        do <= RAM[addr];
    end
end

endmodule