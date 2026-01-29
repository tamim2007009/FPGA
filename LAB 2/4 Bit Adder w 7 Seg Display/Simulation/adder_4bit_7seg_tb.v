// Testbench for 4-Bit Adder with 7-Segment Display
//`timescale 1ns / 1ps

module adder_4bit_7seg_tb;

    reg clk;
    reg [3:0] a, b;
    reg cin;
    wire [3:0] sum_led;
    wire cout_led;
    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate top module
    adder_4bit_7seg_top uut(
        .clk(clk),
        .a(a),
        .b(b),
        .cin(cin),
        .sum_led(sum_led),
        .cout_led(cout_led),
        .seg(seg),
        .an(an)
    );

    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize
        a = 4'b0000;
        b = 4'b0000;
        cin = 0;
        
        #100;
        
        // Test 1: 5 + 3 = 8
        a = 4'd5;
        b = 4'd3;
        cin = 0;
        #10;
        $display("Test 1: %d + %d + %d = %d (sum=%d, cout=%d)", 
                 a, b, cin, {cout_led, sum_led}, sum_led, cout_led);
        
        // Test 2: 15 + 15 = 30
        a = 4'd15;
        b = 4'd15;
        cin = 0;
        #10;
        $display("Test 2: %d + %d + %d = %d (sum=%d, cout=%d)", 
                 a, b, cin, {cout_led, sum_led}, sum_led, cout_led);
        
        // Test 3: 15 + 15 + 1 = 31
        a = 4'd15;
        b = 4'd15;
        cin = 1;
        #10;
        $display("Test 3: %d + %d + %d = %d (sum=%d, cout=%d)", 
                 a, b, cin, {cout_led, sum_led}, sum_led, cout_led);
        
        // Test 4: 0 + 0 = 0
        a = 4'd0;
        b = 4'd0;
        cin = 0;
        #10;
        $display("Test 4: %d + %d + %d = %d (sum=%d, cout=%d)", 
                 a, b, cin, {cout_led, sum_led}, sum_led, cout_led);
        
        $display("All tests completed!");
        $finish;
    end

endmodule