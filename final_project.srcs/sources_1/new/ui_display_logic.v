module ui_display_logic (
    input [3:0] user_id,
    input [3:0] stored_password,
    input [3:0] entered_password,
    input [2:0] state,
    input [3:0] failed_attempts,
    input unlock_led,
    input lockout_led,
    input [3:0] alu_result,
    input zero_flag,
    output reg [127:0] display_text
);

localparam IDLE       = 3'b000;
localparam CHECK      = 3'b001;
localparam OPEN       = 3'b010;
localparam LOCK       = 3'b011;
localparam LOCKED_OUT = 3'b100;

localparam MAX_ATTEMPTS = 4'd3;

// Supported character codes from char_rom.v
localparam CH_0     = 8'd0;
localparam CH_1     = 8'd1;
localparam CH_2     = 8'd2;
localparam CH_3     = 8'd3;
localparam CH_4     = 8'd4;
localparam CH_5     = 8'd5;
localparam CH_6     = 8'd6;
localparam CH_7     = 8'd7;
localparam CH_8     = 8'd8;
localparam CH_9     = 8'd9;
localparam CH_A     = 8'd10;
localparam CH_B     = 8'd11;
localparam CH_C     = 8'd12;
localparam CH_D     = 8'd13;
localparam CH_E     = 8'd14;
localparam CH_F     = 8'd15;
localparam CH_SPACE = 8'd16;
localparam CH_DASH  = 8'd17;
localparam CH_STAR  = 8'd20;

localparam THEME_IDLE    = 8'd0;
localparam THEME_FAIL    = 8'd1;
localparam THEME_SUCCESS = 8'd2;
localparam THEME_LOCKOUT = 8'd3;

reg [3:0] attempts_left;

always @(*) begin
    if (failed_attempts >= MAX_ATTEMPTS)
        attempts_left = 4'd0;
    else
        attempts_left = MAX_ATTEMPTS - failed_attempts;

    display_text = 128'd0;

    // Byte layout consumed by vga_text_display:
    // [127:96]  status code (4 chars)
    // [95:64]   accent/detail code (4 chars)
    // [63:56]   user_id
    // [55:48]   stored_password
    // [47:40]   entered_password
    // [39:32]   attempts_left
    // [31:24]   alu_result
    // [23:16]   compare marker
    // [15:8]    theme id
    // [7:0]     reserved
    display_text[63:56] = {4'b0000, user_id};
    display_text[55:48] = {4'b0000, stored_password};
    display_text[47:40] = {4'b0000, entered_password};
    display_text[39:32] = {4'b0000, attempts_left};
    display_text[31:24] = {4'b0000, alu_result};
    display_text[23:16] = zero_flag ? CH_STAR : CH_DASH;

    if (lockout_led || (state == LOCKED_OUT)) begin
        display_text[127:120] = CH_D;
        display_text[119:112] = CH_E;
        display_text[111:104] = CH_A;
        display_text[103:96]  = CH_D;

        display_text[95:88]   = CH_STAR;
        display_text[87:80]   = CH_STAR;
        display_text[79:72]   = CH_STAR;
        display_text[71:64]   = CH_STAR;

        display_text[15:8]    = THEME_LOCKOUT;
    end
    else if (unlock_led || (state == OPEN)) begin
        display_text[127:120] = CH_A;
        display_text[119:112] = CH_C;
        display_text[111:104] = CH_C;
        display_text[103:96]  = CH_E;

        display_text[95:88]   = CH_STAR;
        display_text[87:80]   = CH_0;
        display_text[79:72]   = CH_STAR;
        display_text[71:64]   = CH_0;

        display_text[15:8]    = THEME_SUCCESS;
    end
    else if ((state == LOCK) || ((state == CHECK) && !zero_flag) || (failed_attempts > 4'd0)) begin
        display_text[127:120] = CH_B;
        display_text[119:112] = CH_A;
        display_text[111:104] = CH_D;
        display_text[103:96]  = CH_DASH;

        display_text[95:88]   = CH_DASH;
        display_text[87:80]   = CH_STAR;
        display_text[79:72]   = CH_STAR;
        display_text[71:64]   = CH_DASH;

        display_text[15:8]    = THEME_FAIL;
    end
    else begin
        display_text[127:120] = CH_C;
        display_text[119:112] = CH_0;
        display_text[111:104] = CH_D;
        display_text[103:96]  = CH_E;

        display_text[95:88]   = CH_DASH;
        display_text[87:80]   = CH_DASH;
        display_text[79:72]   = CH_DASH;
        display_text[71:64]   = CH_DASH;

        display_text[15:8]    = THEME_IDLE;
    end
end

endmodule
