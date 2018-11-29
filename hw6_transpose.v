`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Martin, Michael
//                 Agnesina, Anthony
// 
// Create Date:    
// Design Name: 
// Module Name:    hw6_transpose 
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
module hw6_transpose (
    clk,
    en,
    pixel_in,
    pixel_in_valid,
    pixel_out,
    pixel_out_valid,
);

//Parameters
parameter IDLE = 0;
parameter IN = 1;
parameter WAIT = 2;
parameter OUT = 3;

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
reg write = 0;
reg ram_en = 1;
reg [17:0] address = 0;
reg [7:0] pixel_in_reg = 0;
reg pixel_in_valid_reg = 0;
wire [7:0] pixel_out_sig;
reg pixel_out_valid_sig = 0;
reg [8:0] i_count = 0;
reg [8:0] j_count = 0;
reg [8:0] i_count_sig;
reg [8:0] j_count_sig;
reg [1:0] PS = 0;
reg [1:0] NS;

//Components
hw6_ram ram (
    .clk(clk),
    .en(ram_en),
    .we(write),
    .addr(address),
    .di(pixel_in_reg),
    .do(pixel_out_sig)
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
    i_count <= i_count_sig;
    j_count <= j_count_sig;
end

always @(posedge clk) begin
    PS <= NS;
end

//Combinational Logic
always @(*) begin
    pixel_out_valid_sig = 0;
    address = 0;
    write = 0;
    i_count_sig = i_count;
    j_count_sig = j_count;
    NS = PS;
    case (PS)
        IDLE: begin
            if (en_reg && pixel_in_valid_reg) begin
                write = 1;
                i_count_sig = 1;
                NS = IN;
            end
            else begin
                i_count_sig = 0;
                j_count_sig = 0;
            end
        end
        IN: begin
            if (pixel_in_valid_reg) begin
                write = 1;
                i_count_sig = i_count + 1;
                if (i_count >= 511) begin
                    if (j_count >= 511) begin
                        NS = WAIT;
                    end
                    j_count_sig = j_count + 1;
                end
                address = i_count + (j_count * 512);
            end
        end
        WAIT: begin
            i_count_sig = 1;
            j_count_sig = 0;
            NS = OUT;
        end
        OUT: begin
            pixel_out_valid_sig = 1;
            i_count_sig = i_count + 1;
            if (i_count == 0 && j_count == 0) begin
                NS = IDLE;
            end
            else if (i_count >= 511) begin
                j_count_sig = j_count + 1;
            end
            address = j_count + (i_count * 512);
        end
        default: begin
           NS = IDLE;
        end
    endcase
end

endmodule