module memory (
    input clk,
    input [3:0] password_in,
    input load,
    output reg [3:0] stored_password
);

always @(posedge clk) begin
    if (load)
        stored_password <= password_in;
end

endmodule