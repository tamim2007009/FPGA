// Top Module: 4-Bit Adder with 7-Segment Display
// Integrates adder_4bit with seg_display_controller
// Displays sum (0-31) on 2-digit 7-segment display

module adder_4bit_7seg_top(
    input clk,                // 100MHz clock
    input [3:0] a,            // 4-bit input A (switches 0-3)
    input [3:0] b,            // 4-bit input B (switches 4-7)
    input s0 ,
    input s1 ,
    input cin,                // carry input (switch 8)
    output [3:0] sum_led,     // sum on LEDs (optional)
    output cout_led,          // carry out on LED (optional)
    output [6:0] seg,         // 7-segment cathodes
    output [3:0] an           // 7-segment anodes
);

    wire [3:0] sum;
    wire cout;
    wire [4:0] full_result;
    wire [3:0] bb ;
    wire adder_cin ;

    assign adder_cin = cin | s1 ;
    
    control CL(
        .b(b),
        .s0(s0),
        .s1(s1) ,
        .y(bb)
    );
    
    adder_4bit adder(
        .a(a),
        .b(bb),
        .cin(adder_cin),
        .sum(sum),
        .cout(cout)
    );
    
    // carry and sum for full 5-bit result (0-31)
    // if sub mode, discard carry
    assign full_result = s1 ? {1'b0, sum} : {cout, sum};
    
    assign sum_led = sum;
    assign cout_led = cout;

    seg_display_controller display(
        .clk(clk),
        .value(full_result),
        .seg(seg),
        .an(an)
    );

endmodule