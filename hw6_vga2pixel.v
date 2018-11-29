`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Martin, Michael
//                 Agnesina, Anthony
// 
// Create Date:
// Design Name: 
// Module Name:    hw6_vga2pixel 
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
module hw6_vga2pixel(
    clk,
    R,
    G,
    B,
    HS,
    VS,
    out_pixel,
    out_pixel_valid
);
    
// inputs
input clk;
input [7:0] R, G, B;
input HS, VS;

// outputs
output reg [7:0] out_pixel;
output reg out_pixel_valid;

// signals
reg [7:0] R_reg, G_reg, B_reg;
reg HS_reg, VS_reg;
reg [7:0] pixel;
reg pixel_valid_sig;
reg PS = 0, NS;

// parameters
parameter IDLE   = 0;
parameter ACTIVE = 1;

// input registers
always @(posedge clk) begin
    R_reg <= R;
    G_reg <= G;
    B_reg <= B;
    HS_reg <= HS;
    VS_reg <= VS;
end

// output registers
always @(posedge clk) begin
    out_pixel <= pixel;
    out_pixel_valid <= pixel_valid_sig;
end

// sequential logic
always @(posedge clk) begin
    PS <= NS;
end

//===========================================================
// PARAMETERS
//===========================================================
parameter counter_wid = 32;

//--------------------------------------------------------
//Image Details
//--------------------------------------------------------
parameter bit_depth = 8;
//Number of rows and cols in the input image
parameter rows = 512;
parameter cols = 512;

//--------------------------------------------------------
//VGA Details
//--------------------------------------------------------
parameter VGA_pixels = 800;
parameter VGA_lines = 600;

parameter HS_front_porch = 40;
parameter HS_sync_pulse = 128 + HS_front_porch; //this is looking at the total count. So we are making a running sum.
parameter HS_back_porch = 88 + HS_sync_pulse;   //this is looking at the total count. So we are making a running sum.

parameter VS_front_porch = 1;
parameter VS_sync_pulse = 4 + VS_front_porch;   //this is looking at the total count. So we are making a running sum.
parameter VS_back_porch = 23 + VS_sync_pulse;       //this is looking at the total count. So we are making a running sum.

parameter HS_total_pixels = VGA_pixels+HS_back_porch;
parameter VS_total_pixels = VGA_lines+VS_back_porch;

//--------------------------------------------------------
//Counters to keep track of screen location
//--------------------------------------------------------
//Timings for 800*600 VGA resolution (W*H)
reg [10:0] counterX = 0;
reg [9:0] counterY = 0;
reg en_vga_counters = 0;

always @(posedge clk)
    if(en_vga_counters) begin
        if(counterX < (HS_total_pixels-1))
            counterX <= counterX + 1;           //Whole row is 1056 pixels wide
        else begin                  
            counterX <= 0;
            if(counterY < (VS_total_pixels-1))
                counterY <= counterY + 1;       //Whole column is 628 pixels high
            else
                counterY <= 0;
            end
    end
    else begin
        counterY = VS_front_porch;
        counterX = 1;
    end
        

//--------------------------------------------------------
//Horizontal and Vertical Sync Signals
//--------------------------------------------------------
wire HS_FP = (counterX < HS_front_porch);       //Front Porch
wire HS_SY = (counterX >= HS_front_porch) && (counterX < HS_sync_pulse);    //Sync Pulse (128)
wire HS_BP = (counterX >= HS_sync_pulse) && (counterX < HS_back_porch); //Back Porch (88)
wire HS_DI = (counterX >= HS_back_porch);       //Display Region
wire pixel_valid = HS_DI && (counterX < HS_back_porch + cols);  //Image is only 512 columns wide

wire VS_FP = (counterY < VS_front_porch);       //Front Porch
wire VS_SY = (counterY >= VS_front_porch) && (counterY < VS_sync_pulse);    //Sync Pulse (4)
wire VS_BP = (counterY >= VS_sync_pulse) && (counterY < VS_back_porch); //Back Porch (23)
wire VS_DI = (counterY >= VS_back_porch);       //Display Region
wire line_valid = VS_DI && (counterY < VS_back_porch + rows);                           //Image is only 512 rows wide

// combinational logic
always @(*) begin
    pixel_valid_sig = line_valid && pixel_valid;
    pixel = R_reg;
    NS = PS;
    en_vga_counters = 0;
    case (PS)
        IDLE:       if (!VS_reg) NS = ACTIVE;
        ACTIVE:     en_vga_counters = 1;
        default:    NS = IDLE;
    endcase
end

endmodule
