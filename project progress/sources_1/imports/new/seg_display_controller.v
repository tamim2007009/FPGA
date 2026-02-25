module seg_display_controller(
    input clk,
    input  [7:0] value,      // 8-bit product
    output [6:0] seg,
    output reg [3:0] an
);

reg [17:0] refresh_counter = 0;
wire digit_select;

reg [3:0] current_digit;

// Split into HEX digits
wire [3:0] lower = value[3:0];
wire [3:0] upper = value[7:4];

always @(posedge clk)
    refresh_counter <= refresh_counter + 1;

assign digit_select = refresh_counter[17];

always @(*) begin
    case(digit_select)
        1'b0: begin
            an[3:2] = 2'b11;
            an[1]   = 1'b1;
            an[0]   = 1'b0;     // Rightmost digit
            current_digit = lower;
        end
        1'b1: begin
            an[3:2] = 2'b11;
            an[1]   = 1'b0;     // Next digit
            an[0]   = 1'b1;
            current_digit = upper;
        end
        default: begin
            an = 4'b1111;
            current_digit = 4'h0;
        end
    endcase
end

hex_to_seven_seg decoder(
    .hex(current_digit),
    .seg(seg)
);

endmodule
