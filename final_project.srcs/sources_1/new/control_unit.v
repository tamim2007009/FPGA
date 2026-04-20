module control_unit (
    input clk,
    input reset,
    input match,
    input enter,
    output reg unlock,
    output reg lockout_active,
    output reg [2:0] current_state,
    output reg [3:0] failed_attempts_out
);

reg [2:0] state;
reg [3:0] failed_attempts;       // Counter for failed password attempts
reg [23:0] lockout_timer;        // Timer for lockout duration

// State parameters
parameter IDLE = 3'b000,
          CHECK = 3'b001,
          OPEN = 3'b010,
          LOCK = 3'b011,
          LOCKED_OUT = 3'b100;

// Anti-brute-force parameters
parameter MAX_ATTEMPTS = 4'd3,                    // 3 failed attempts before lockout
          LOCKOUT_DURATION = 24'd5000000;         // ~100ms at 50MHz clock

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        failed_attempts <= 4'd0;
        lockout_timer <= 24'd1;
    end
    else begin
        case(state)
            IDLE: begin
                lockout_timer <= 24'd0;
                if (enter)
                    state <= CHECK;
            end

            CHECK: begin
                if (match) begin
                    // Correct password
                    state <= OPEN;
                    failed_attempts <= 4'd0;  // Reset counter on success
                end
                else begin
                    // Incorrect password
                    if (failed_attempts >= (MAX_ATTEMPTS - 1)) begin
                        state <= LOCKED_OUT;
                        lockout_timer <= 24'd0;
                    end
                    else begin
                        state <= LOCK;
                        failed_attempts <= failed_attempts + 1;
                    end
                end
            end

            LOCK: begin
                state <= LOCK;  // Stay locked until reset
            end

            OPEN: begin
                state <= OPEN;  // Stay unlocked until reset
            end

            LOCKED_OUT: begin
                if (lockout_timer >= LOCKOUT_DURATION) begin
                    state <= IDLE;
                    failed_attempts <= 4'd0;
                    lockout_timer <= 24'd0;
                end
                else begin
                    lockout_timer <= lockout_timer + 1;
                end
            end

            default: state <= IDLE;
        endcase
    end
end

always @(*) begin
    unlock = (state == OPEN);
    lockout_active = (state == LOCKED_OUT);
    current_state = state;
    failed_attempts_out = failed_attempts;
end

endmodule