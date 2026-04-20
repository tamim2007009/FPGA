module memory (
    input clk,
    input [3:0] password_in,
    input [3:0] user_id,
    input load,
    output reg [3:0] stored_password
);

reg [3:0] passwords [15:0];  // 16 users, 4-bit passwords each

// Write operation: store password at user_id location
always @(posedge clk) begin
    if (load)
        passwords[user_id] <= password_in;
end

// Read operation: always output the password for the current user_id
always @(*) begin
    stored_password = passwords[user_id];
end

endmodule