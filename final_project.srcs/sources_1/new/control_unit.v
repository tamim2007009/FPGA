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
reg [3:0] lockout_round;         // Number of lockout rounds reached so far
reg [31:0] lockout_timer;        // Timer for lockout duration
reg [31:0] active_lockout_duration; // Duration used for the current lockout round

// State parameters
parameter IDLE = 3'b000,
          CHECK = 3'b001,
          OPEN = 3'b010,
          LOCK = 3'b011,
          LOCKED_OUT = 3'b100;

// Anti-brute-force parameters
parameter MAX_ATTEMPTS = 4'd3,                    // 3 failed attempts before lockout
          LOCKOUT_DURATION = 32'd100000000;       // Base duration: ~1s at 100MHz clock

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        failed_attempts <= 4'd0;
        lockout_round <= 4'd0;
        lockout_timer <= 32'd0;
        active_lockout_duration <= LOCKOUT_DURATION;
    end
    else begin
        case(state)
            IDLE: begin
                lockout_timer <= 32'd0;
                if (enter)
                    state <= CHECK;
            end

            CHECK: begin
                if (match) begin
                    // Correct password
                    state <= OPEN;
                    failed_attempts <= 4'd0;  // Reset counter on success
                    lockout_round <= 4'd0;
                    active_lockout_duration <= LOCKOUT_DURATION;
                end
                else begin
                    // Incorrect password
                    if (failed_attempts >= (MAX_ATTEMPTS - 1)) begin
                        state <= LOCKED_OUT;
                        failed_attempts <= MAX_ATTEMPTS;
                        lockout_timer <= 32'd0;
                        if (lockout_round == 4'd0)
                            active_lockout_duration <= LOCKOUT_DURATION;
                        else
                            active_lockout_duration <= LOCKOUT_DURATION * (lockout_round << 1);
                        lockout_round <= lockout_round + 1;
                    end
                    else begin
                        state <= LOCK;
                        failed_attempts <= failed_attempts + 1;
                    end
                end
            end

            LOCK: begin
                // Hold the failed-attempt indication until enter is released.
                if (!enter)
                    state <= IDLE;
            end

            OPEN: begin
                state <= OPEN;  // Stay unlocked until reset
            end

            LOCKED_OUT: begin
                if (lockout_timer >= active_lockout_duration) begin
                    state <= IDLE;
                    failed_attempts <= 4'd0;
                    lockout_timer <= 32'd0;
                end
                else begin
                    lockout_timer <= lockout_timer + 1;
                end
            end

            default: state <= IDLE;
        endcase
    end
end

always @(*) begin // this is a combinational logic
    unlock = (state == OPEN);
    lockout_active = (state == LOCKED_OUT);
    current_state = state;
    failed_attempts_out = failed_attempts;
end

endmodule
