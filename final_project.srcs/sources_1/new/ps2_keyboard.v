module ps2_keyboard (
    input clk,              // 100 MHz clock
    input reset,
    input ps2_clk,          // PS/2 clock from keyboard
    input ps2_data,         // PS/2 data from keyboard
    output reg [7:0] key_code,    // ASCII code or scan code
    output reg key_valid    // High when new key received
);

// PS/2 receiver logic
reg ps2_clk_r, ps2_clk_rr;
reg ps2_data_r, ps2_data_rr;
reg [10:0] ps2_buffer;
reg [3:0] bit_count;
reg receiving;

wire ps2_clk_fall = ps2_clk_rr && ~ps2_clk_r;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        ps2_clk_r <= 1'b1;
        ps2_clk_rr <= 1'b1;
        ps2_data_r <= 1'b1;
        ps2_data_rr <= 1'b1;
        ps2_buffer <= 11'd0;
        bit_count <= 4'd0;
        receiving <= 1'b0;
        key_code <= 8'd0;
        key_valid <= 1'b0;
    end
    else begin
        // Synchronize inputs
        ps2_clk_r <= ps2_clk;
        ps2_clk_rr <= ps2_clk_r;
        ps2_data_r <= ps2_data;
        ps2_data_rr <= ps2_data_r;
        
        key_valid <= 1'b0;  // Pulse output
        
        if (ps2_clk_fall) begin
            if (bit_count == 0 && ps2_data_rr == 0) begin
                // Start bit detected
                receiving <= 1'b1;
                bit_count <= 4'd1;
            end
            else if (receiving && bit_count < 10) begin
                // Receive 8 data bits
                ps2_buffer[bit_count - 1] <= ps2_data_rr;
                bit_count <= bit_count + 1;
            end
            else if (bit_count == 10) begin
                // Stop bit
                key_code <= ps2_buffer[7:0];
                key_valid <= 1'b1;
                bit_count <= 4'd0;
                receiving <= 1'b0;
            end
        end
    end
end

endmodule
