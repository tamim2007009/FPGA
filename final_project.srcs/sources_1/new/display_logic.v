module display_logic (
    input [2:0] state,
    input [3:0] failed_attempts,
    input [3:0] user_id,
    output reg [3:0] display_value
);

// State parameters (must match control_unit)
parameter IDLE = 3'b000,
          CHECK = 3'b001,
          OPEN = 3'b010,
          LOCK = 3'b011,
          LOCKED_OUT = 3'b100;

parameter MAX_ATTEMPTS = 4'd3;

always @(*) begin
    case(state)
        OPEN: begin
            // Show user ID when authenticated
            display_value = user_id;
        end
        IDLE, CHECK, LOCK: begin
            // Show remaining attempts whenever the user is not authenticated.
            display_value = (MAX_ATTEMPTS - failed_attempts);
        end
        LOCKED_OUT: begin
            // Show 0 (zero attempts remaining) during lockout
            display_value = 4'd0;
        end
        default: display_value = 4'd0;
    endcase
end

endmodule
