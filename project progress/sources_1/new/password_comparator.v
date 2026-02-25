// Password Comparator Module for Door Lock System
module password_comparator(
    input clk,
    input check_btn,
    input [3:0] password_input,
    output reg match,
    output reg [7:0] display_out
);

// Predefined password (you can change this value)
localparam [3:0] CORRECT_PASSWORD = 4'b1010;  // Password = 1010 (binary)

reg [3:0] stored_password;
reg btn_prev;
wire btn_pressed;

// Detect button press (rising edge)
always @(posedge clk) begin
    btn_prev <= check_btn;
end

assign btn_pressed = check_btn & ~btn_prev;

// Comparator logic
always @(posedge clk) begin
    if(btn_pressed) begin
        stored_password <= password_input;
        
        // Binary comparison
        if(password_input == CORRECT_PASSWORD) begin
            match <= 1'b1;          // Password matches - Door UNLOCK
            display_out <= {4'h0, password_input};   // Display 0X = Unlocked (X = input)
        end
        else begin
            match <= 1'b0;          // Password wrong - Door LOCKED
            display_out <= {4'hE, password_input};   // Display EX = Locked (X = input)
        end
    end
end

endmodule
