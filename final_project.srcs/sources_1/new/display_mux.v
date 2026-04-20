module display_mux (
    input clk,
    input [3:0] digit_value,
    output reg [6:0] seven_segment,
    output reg [3:0] anode_enable
);

// Display multiplexing: Show digit on one position at a time
// Since we only have one 4-bit value, we'll display it on digit 0 (rightmost)
// and keep others blank

reg [18:0] mux_counter;  // Counter for display refresh rate
wire [1:0] digit_select;

assign digit_select = mux_counter[18:17];  // Selects which digit to display

// Seven-segment decoder with INVERTED output for common anode
// For common anode: segments are ON when driven LOW
always @(*) begin
    case(digit_value)
        4'd0: seven_segment = 7'b1000000;  // 0: segments a,b,c,d,e,f
        4'd1: seven_segment = 7'b1111001;  // 1: segments b,c
        4'd2: seven_segment = 7'b0100100;  // 2: segments a,b,d,e,g
        4'd3: seven_segment = 7'b0110000;  // 3: segments a,b,c,d,g
        4'd4: seven_segment = 7'b0011001;  // 4: segments b,c,f,g
        4'd5: seven_segment = 7'b0010010;  // 5: segments a,c,d,f,g
        4'd6: seven_segment = 7'b0000010;  // 6: segments a,c,d,e,f,g
        4'd7: seven_segment = 7'b1111000;  // 7: segments a,b,c
        4'd8: seven_segment = 7'b0000000;  // 8: all segments
        4'd9: seven_segment = 7'b0010000;  // 9: segments a,b,c,d,f,g
        4'd10: seven_segment = 7'b0001000; // A: segments a,b,c,e,f,g
        4'd11: seven_segment = 7'b0000011; // B: segments c,d,e,f,g
        4'd12: seven_segment = 7'b1000110; // C: segments a,d,e,f
        4'd13: seven_segment = 7'b0100001; // D: segments b,c,d,e,g
        4'd14: seven_segment = 7'b0000110; // E: segments a,d,e,f,g
        4'd15: seven_segment = 7'b0001110; // F: segments a,e,f,g
        default: seven_segment = 7'b1111111; // blank
    endcase
end

// Anode multiplexer: Select which digit to display
// Drive anode LOW to enable (active low for common anode with transistor driver)
always @(*) begin
    case(digit_select)
        2'b00: anode_enable = 4'b1110;  // Digit 0 ON, others OFF
        2'b01: anode_enable = 4'b1101;  // Digit 1 ON
        2'b10: anode_enable = 4'b1011;  // Digit 2 ON
        2'b11: anode_enable = 4'b0111;  // Digit 3 ON
        default: anode_enable = 4'b1111; // All OFF
    endcase
end

// Increment multiplexer counter on each clock
always @(posedge clk) begin
    mux_counter <= mux_counter + 1;
end

endmodule
