// Testbench for 4-Bit ALU (Adder/Subtractor) with 7-Segment Display
//`timescale 1ns / 1ps
module adder_4bit_7seg_tb;
    reg clk;
    reg [3:0] a, b;
    reg s0, s1;
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
        .s0(s0),
        .s1(s1),
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
        s0 = 0;
        s1 = 0;
        cin = 0;
        
        #10;
        
        $display("========== ADDITION TESTS (s0=1, s1=0) ==========");
        
        // Test 1: 5 + 3 = 8
        a = 4'd5;
        b = 4'd3;
        s0 = 1; s1 = 0;
        cin = 0;
        #10;
        $display("Test 1: %d + %d = %d (sum=%d, cout=%d)", 
                 a, b, {cout_led, sum_led}, sum_led, cout_led);
        
        // Test 2: 15 + 15 = 30
        a = 4'd15;
        b = 4'd15;
        s0 = 1; s1 = 0;
        cin = 0;
        #10;
        $display("Test 2: %d + %d = %d (sum=%d, cout=%d)", 
                 a, b, {cout_led, sum_led}, sum_led, cout_led);
        
        // Test 3: 7 + 8 = 15
        a = 4'd7;
        b = 4'd8;
        s0 = 1; s1 = 0;
        cin = 0;
        #10;
        $display("Test 3: %d + %d = %d (sum=%d, cout=%d)", 
                 a, b, {cout_led, sum_led}, sum_led, cout_led);
        
        // Test 4: 0 + 0 = 0
        a = 4'd0;
        b = 4'd0;
        s0 = 1; s1 = 0;
        cin = 0;
        #10;
        $display("Test 4: %d + %d = %d (sum=%d, cout=%d)", 
                 a, b, {cout_led, sum_led}, sum_led, cout_led);
        
        $display("");
        $display("========== SUBTRACTION TESTS (s0=0, s1=1) ==========");
        
        // Test 5: 8 - 3 = 5
        a = 4'd8;
        b = 4'd3;
        s0 = 0; s1 = 1;
        cin = 0;
        #10;
        $display("Test 5: %d - %d = %d (sum=%d, cout=%d)", 
                 a, b, sum_led, sum_led, cout_led);
        
        // Test 6: 15 - 7 = 8
        a = 4'd15;
        b = 4'd7;
        s0 = 0; s1 = 1;
        cin = 0;
        #10;
        $display("Test 6: %d - %d = %d (sum=%d, cout=%d)", 
                 a, b, sum_led, sum_led, cout_led);
        
        // Test 7: 0 - 0 = 0
        a = 4'd0;
        b = 4'd0;
        s0 = 0; s1 = 1;
        cin = 0;
        #10;
        $display("Test 7: %d - %d = %d (sum=%d, cout=%d)", 
                 a, b, sum_led, sum_led, cout_led);
        
        // Test 8: 10 - 10 = 0
        a = 4'd10;
        b = 4'd10;
        s0 = 0; s1 = 1;
        cin = 0;
        #10;
        $display("Test 8: %d - %d = %d (sum=%d, cout=%d)", 
                 a, b, sum_led, sum_led, cout_led);
        
        // Test 9: 5 - 3 = 2
        a = 4'd5;
        b = 4'd3;
        s0 = 0; s1 = 1;
        cin = 0;
        #10;
        $display("Test 9: %d - %d = %d (sum=%d, cout=%d)", 
                 a, b, sum_led, sum_led, cout_led);
        
        // Test 10: 3 - 5 = -2 (shows as 14 in unsigned, 2's complement)
        a = 4'd3;
        b = 4'd5;
        s0 = 0; s1 = 1;
        cin = 0;
        #10;
        $display("Test 10: %d - %d = %d (negative result, 2's complement)", 
                 a, b, sum_led);
        
        $display("");
        $display("========== PASS-THROUGH TEST (s0=0, s1=0) ==========");
        
        // Test 11: When s0=0, s1=0, bb=0, so A + 0 = A
        a = 4'd7;
        b = 4'd9;
        s0 = 0; s1 = 0;
        cin = 0;
        #10;
        $display("Test 11: A=%d, B=%d, s0=0, s1=0 -> result=%d (A + 0)", 
                 a, b, sum_led);
        
        $display("");
        $display("All tests completed!");
        $finish;
    end
endmodule