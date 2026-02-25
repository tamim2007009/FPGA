module basys3_password_lock(
    input clk,
    input btnC,              // Check password button
    input [15:0] sw,         // sw[3:0] = 4-bit password input
    output [6:0] seg,
    output [3:0] an,
    output reg [15:0] led    // LEDs to show status
);

wire password_match;
wire [7:0] display_value;

// Password comparator
password_comparator comparator(
    .clk(clk),
    .check_btn(btnC),
    .password_input(sw[3:0]),
    .match(password_match),
    .display_out(display_value)
);

// Display controller
seg_display_controller display(
    .clk(clk),
    .value(display_value),
    .seg(seg),
    .an(an)
);

// LED indication
always @(posedge clk) begin
    if(password_match)
        led <= 16'hFFFF;  // All LEDs ON = Door Unlocked
    else
        led <= 16'h0000;  // All LEDs OFF = Door Locked
end

endmodule
