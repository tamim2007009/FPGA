`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2026 07:42:36 PM
// Design Name: 
// Module Name: tb_top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: `timescale 1ns / 1ps

module tb_top_module;

// Inputs
reg clk;
reg reset;
reg enter;
reg load;
reg [3:0] switch_input;
reg [3:0] user_id;
reg ps2_clk;
reg ps2_data;

// Outputs
wire unlock_led;
wire lockout_led;
wire [6:0] seven_segment;
wire [3:0] anode_enable;
wire vga_hsync, vga_vsync;
wire [3:0] vga_red, vga_green, vga_blue;

// Instantiate DUT (Device Under Test)
top_module uut (
    .clk(clk),
    .reset(reset),
    .enter(enter),
    .load(load),
    .switch_input(switch_input),
    .user_id(user_id),
    .unlock_led(unlock_led),
    .lockout_led(lockout_led),
    .seven_segment(seven_segment),
    .anode_enable(anode_enable),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync),
    .vga_red(vga_red),
    .vga_green(vga_green),
    .vga_blue(vga_blue),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data)
);

// Clock generation (100MHz ? 10ns period)
always #5 clk = ~clk;

// Test sequence
initial begin
    // Initialize
    clk = 0;
    reset = 1;
    enter = 0;
    load = 0;
    switch_input = 4'b0000;
    user_id = 4'b0000;
    ps2_clk = 1'b1;    // PS/2 idle
    ps2_data = 1'b1;   // PS/2 idle  // User 0

    // Reset system
    #10;
    reset = 0;

    // ? STEP 1: Set password = 1010 for user 0
    #10;
    user_id = 4'b0000;
    switch_input = 4'b1010;
    load = 1;
    #10;
    load = 0;

    // ? STEP 2: Enter WRONG password = 1111
    #10;
    user_id = 4'b0000;
    switch_input = 4'b1111;
    enter = 1;
    #10;
    enter = 0;

    // Wait for state transition
    #20;

    // ? STEP 3: Enter CORRECT password = 1010
    #10;
    user_id = 4'b0000;
    switch_input = 4'b1010;
    enter = 1;
    #10;
    enter = 0;

    // Wait for unlock
    #50;

    // Finish simulation
    $stop;
end

endmodule
