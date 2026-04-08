module control_unit (
    input clk,
    input reset,
    input match,
    input enter,
    output reg unlock
);

reg [1:0] state;

parameter IDLE = 2'b00,
          CHECK = 2'b01,
          OPEN = 2'b10,
          LOCK = 2'b11;

always @(posedge clk or posedge reset) begin
    if (reset)
        state <= IDLE;
    else begin
        case(state)
            IDLE: if (enter) state <= CHECK;
            CHECK: state <= (match) ? OPEN : LOCK;
            OPEN: state <= OPEN;
            LOCK: state <= LOCK;
        endcase
    end
end

always @(*) begin
    unlock = (state == OPEN);
end

endmodule