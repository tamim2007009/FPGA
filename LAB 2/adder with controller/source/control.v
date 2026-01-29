module control(
    input [3:0] b,
    input s0,
    input s1,
    output [3:0] y
);
    assign y = s1 ? (~b) : (s0 ? b : 4'b0000);
endmodule