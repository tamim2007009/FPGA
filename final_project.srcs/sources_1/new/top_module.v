module top_module (
    input clk,
    input reset,
    input enter,
    input load,
    input [3:0] switch_input,
    input [3:0] user_id,
    output unlock_led,
    output lockout_led,
    output [6:0] seven_segment,
    output [3:0] anode_enable
);

wire [3:0] stored_password;
wire [3:0] alu_result;
wire zero_flag;
wire [2:0] cu_state;
wire [3:0] cu_failed_attempts;
wire [3:0] display_value;

// For comparison, we'll use the subtraction opcode
wire [3:0] alu_opcode = 4'b0100;

memory mem (
    .clk(clk),
    .password_in(switch_input),
    .user_id(user_id),
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
    .unlock(unlock_led),
    .lockout_active(lockout_led),
    .current_state(cu_state),
    .failed_attempts_out(cu_failed_attempts)
);

display_logic disp_logic (
    .state(cu_state),
    .failed_attempts(cu_failed_attempts),
    .user_id(user_id),
    .display_value(display_value)
);

display_mux mux_7seg (
    .clk(clk),
    .digit_value(display_value),
    .seven_segment(seven_segment),
    .anode_enable(anode_enable)
);

endmodule