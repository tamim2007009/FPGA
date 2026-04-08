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

// Output
wire unlock_led;

// Instantiate DUT (Device Under Test)
top_module uut (
    .clk(clk),
    .reset(reset),
    .enter(enter),
    .load(load),
    .switch_input(switch_input),
    .unlock_led(unlock_led)
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

    // Reset system
    #10;
    reset = 0;

    // ? STEP 1: Set password = 1010
    #10;
    switch_input = 4'b1010;
    load = 1;
    #10;
    load = 0;

    // ? STEP 2: Enter WRONG password = 1111
    #10;
    switch_input = 4'b1111;
    enter = 1;
    #10;
    enter = 0;

    // Wait
    #20;

    // ? STEP 3: Enter CORRECT password = 1010
    #10;
    switch_input = 4'b1010;
    enter = 1;
    #10;
    enter = 0;

    // Wait
    #30;

    // Finish simulation
    $stop;
end

endmodule
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_top_module(

    );
endmodule
