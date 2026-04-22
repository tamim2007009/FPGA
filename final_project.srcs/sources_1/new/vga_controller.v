module vga_controller (
    input clk,              // 100 MHz clock
    input reset,
    output hsync,           // Horizontal sync
    output vsync,           // Vertical sync
    output [9:0] pixel_x,   // Current pixel X (0-639)
    output [9:0] pixel_y,   // Current pixel Y (0-479)
    output valid_pixel      // High when in active display area
);

// VGA timing parameters for 640x480 @ 60Hz
// Pixel clock = 25 MHz (divide 100MHz by 4)
parameter H_TOTAL = 800;
parameter H_ACTIVE = 640;
parameter H_FRONT_PORCH = 16;
parameter H_SYNC_PULSE = 96;

parameter V_TOTAL = 525;
parameter V_ACTIVE = 480;
parameter V_FRONT_PORCH = 10;
parameter V_SYNC_PULSE = 2;

reg [9:0] h_count, v_count;
reg [1:0] clk_div;  // Clock divider for 25MHz

always @(posedge clk or posedge reset) begin
    if (reset) begin
        clk_div <= 2'b00;
        h_count <= 10'b0;
        v_count <= 10'b0;
    end
    else begin
        clk_div <= clk_div + 1;
        
        if (clk_div == 2'b11) begin  // Every 4th clock = 25MHz
            if (h_count == (H_TOTAL - 1)) begin
                h_count <= 10'b0;
                if (v_count == (V_TOTAL - 1))
                    v_count <= 10'b0;
                else
                    v_count <= v_count + 1;
            end
            else
                h_count <= h_count + 1;
        end
    end
end

// Generate sync signals
assign hsync = ~((h_count >= (H_ACTIVE + H_FRONT_PORCH)) && 
                 (h_count < (H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE)));

assign vsync = ~((v_count >= (V_ACTIVE + V_FRONT_PORCH)) && 
                 (v_count < (V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE)));

// Active pixel area
assign valid_pixel = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);

assign pixel_x = h_count;
assign pixel_y = v_count;

endmodule
