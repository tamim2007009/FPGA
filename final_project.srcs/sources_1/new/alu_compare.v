module alu (
    input [3:0] a,
    input [3:0] b,
    input [3:0] opcode,
    output reg [3:0] result,
    output reg zero
);

wire [3:0] temp_result;

always @(*) begin
    case(opcode)
        4'b0000: result = a + b;      // Addition
        4'b0001: result = a - b;      // Subtraction
        4'b0010: result = a & b;      // AND
        4'b0011: result = a | b;      // OR
        4'b0100: result = a - b;      // Compare by subtraction
        default: result = 4'b0000;
    endcase
    
    // Zero flag: set if opcode is COMPARE (0100) and result is zero
    if ((opcode == 4'b0100) && (result == 4'b0000))
        zero = 1;
    else
        zero = 0;
end

endmodule