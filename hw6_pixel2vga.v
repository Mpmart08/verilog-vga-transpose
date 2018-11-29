`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:       Martin, Michael
//                 Agnesina, Anthony
// 
// Create Date:    
// Design Name: 
// Module Name:    hw6_pixel2vga 
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
module hw6_pixel2vga(clk, pixel_in, pixel_in_valid, R, G, B, HS, VS);
    
    //Inputs
    input clk;
    input [7:0] pixel_in;
    input pixel_in_valid;

    //Outputs
    output reg [7:0] R, G, B;
    output reg HS, VS;

    //Resynchro sigs
    wire [7:0] R_sig, G_sig, B_sig;
    wire HS_sig, VS_sig;
    reg [7:0] pixel_in_reg;
    reg pixel_valid_reg;

    //Parameters of FIFO
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 18;

    //States FSM
    reg PS = 0, NS;

    //Parameters FSM
    parameter IDLE   = 0;
    parameter ACTIVE = 1;

    //Register the inputs
    always @(posedge clk) 
    begin
        pixel_in_reg <= pixel_in;
        pixel_valid_reg <= pixel_in_valid;
    end

    //Register the outputs
    always @(posedge clk) 
    begin
        R <= R_sig;
        G <= G_sig;
        B <= B_sig;
        HS <= HS_sig;
        VS <= VS_sig;
    end

    parameter counter_wid = 32;

    parameter bit_depth = 8;

    parameter rows = 512;
    parameter cols = 512;

    parameter VGA_pixels = 800;
    parameter VGA_lines = 600;

    parameter HS_front_porch = 40;
    parameter HS_sync_pulse = 128 + HS_front_porch; 
    parameter HS_back_porch = 88 + HS_sync_pulse;   

    parameter VS_front_porch = 1;
    parameter VS_sync_pulse = 4 + VS_front_porch;   
    parameter VS_back_porch = 23 + VS_sync_pulse;   

    parameter HS_total_pixels = VGA_pixels+HS_back_porch;
    parameter VS_total_pixels = VGA_lines+VS_back_porch;


    reg [10:0] counterX = 0;
    reg [9:0] counterY = 0;
    reg en_vga_counters = 0;

    //Counters
    always @(posedge clk)
        if(en_vga_counters)
            if(counterX < (HS_total_pixels-1))
                counterX <= counterX + 1;           
            else begin                  
                counterX <= 0;
                if(counterY < (VS_total_pixels-1))
                    counterY <= counterY + 1;       
                else
                    counterY <= 0;
                end


    wire HS_FP = (counterX < HS_front_porch);       
    wire HS_SY = (counterX >= HS_front_porch) && (counterX < HS_sync_pulse);    
    wire HS_BP = (counterX >= HS_sync_pulse) && (counterX < HS_back_porch); 
    wire HS_DI = (counterX >= HS_back_porch);       
    wire pixel_valid = HS_DI && (counterX < HS_back_porch + cols); 

    wire VS_FP = (counterY < VS_front_porch);       
    wire VS_SY = (counterY >= VS_front_porch) && (counterY < VS_sync_pulse);    
    wire VS_BP = (counterY >= VS_sync_pulse) && (counterY < VS_back_porch); 
    wire VS_DI = (counterY >= VS_back_porch);       
    wire line_valid = VS_DI && (counterY < VS_back_porch + rows);                           

    wire image_pixel_valid = line_valid && pixel_valid;
                               
    assign HS_sig = ~HS_SY;             
    assign VS_sig = ~VS_SY;   

    wire [7:0] data_out;
    wire fifo_empty;
    wire fifo_full;
    wire fifo_overflow;

    simpleFIFO #(DATA_WIDTH,ADDR_WIDTH) fifo(
        .clk(clk),
        .reset(1'b0),
        .data_in(pixel_in_reg),
        .rd_ack_in(image_pixel_valid),
        .wr_en_in(pixel_valid_reg),
        .data_out(data_out),
        .empty_out(fifo_empty),
        .full_out(fifo_full),
        .overflow_out(fifo_overflow)
    );          

    assign R_sig = (image_pixel_valid) ? data_out : 8'd0;      
    assign G_sig = (image_pixel_valid) ? data_out : 8'd0;
    assign B_sig = (image_pixel_valid) ? data_out : 8'd0;


    ///// FSM /////
    //Seq Logic
    always @(posedge clk) 
    begin
        PS <= NS;
    end

    //Comb Logic
    always @(*) 
    begin
        en_vga_counters = 0;
        NS = PS;
        case (PS)
            IDLE:       if (pixel_valid_reg) NS = ACTIVE;
            ACTIVE:     en_vga_counters = 1;
            default:    NS = IDLE;
        endcase
    end

endmodule
