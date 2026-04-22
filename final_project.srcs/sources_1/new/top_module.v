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
    output [3:0] anode_enable,
    // VGA outputs
    output vga_hsync,
    output vga_vsync,
    output [3:0] vga_red,
    output [3:0] vga_green,
    output [3:0] vga_blue,
    // PS/2 keyboard inputs
    input ps2_clk,
    input ps2_data
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

// VGA Controller
wire [9:0] pixel_x, pixel_y;
wire valid_pixel;
vga_controller vga_ctrl (
    .clk(clk),
    .reset(reset),
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .valid_pixel(valid_pixel)
);

// PS/2 Keyboard
wire [7:0] key_code;
wire key_valid;
ps2_keyboard kbd (
    .clk(clk),
    .reset(reset),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .key_code(key_code),
    .key_valid(key_valid)
);

// UI Display Logic
wire [127:0] display_text;
ui_display_logic ui_logic (
    .user_id(user_id),
    .stored_password(stored_password),
    .entered_password(switch_input),
    .state(cu_state),
    .failed_attempts(cu_failed_attempts),
    .unlock_led(unlock_led),
    .lockout_led(lockout_led),
    .alu_result(alu_result),
    .zero_flag(zero_flag),
    .display_text(display_text)
);

// VGA Text Display
vga_text_display vga_text (
    .clk(clk),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .valid_pixel(valid_pixel),
    .display_text(display_text),
    .red(vga_red),
    .green(vga_green),
    .blue(vga_blue)
);

endmodule