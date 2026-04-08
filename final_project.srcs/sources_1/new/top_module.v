module top_module (
    input clk,
    input reset,
    input enter,
    input load,
    input [3:0] switch_input,
    output unlock_led
);

wire [3:0] stored_password;
wire [3:0] alu_result;
wire zero_flag;

// For comparison, we'll use the subtraction opcode
wire [3:0] alu_opcode = 4'b0100;

memory mem (
    .clk(clk),
    .password_in(switch_input),
    .load(load),
    .stored_password(stored_password)
);

alu alu_unit (
    .a(switch_input),
    .b(stored_password),
    .opcode(alu_opcode),
    .result(alu_result),
    .zero(zero_flag)
);

control_unit cu (
    .clk(clk),
    .reset(reset),
    .match(zero_flag),
    .enter(enter),
    .unlock(unlock_led)
);

endmodule