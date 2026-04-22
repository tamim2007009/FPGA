module vga_text_display (
    input clk,
    input [9:0] pixel_x,
    input [9:0] pixel_y,
    input valid_pixel,
    input [127:0] display_text,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);

localparam CH_SPACE = 8'd16;

localparam THEME_IDLE    = 8'd0;
localparam THEME_FAIL    = 8'd1;
localparam THEME_SUCCESS = 8'd2;
localparam THEME_LOCKOUT = 8'd3;

localparam TONE_STATUS = 2'd0;
localparam TONE_TILE   = 2'd1;
localparam TONE_ALERT  = 2'd2;

function [7:0] get_char;
    input [3:0] index;
    begin
        case (index)
            4'd0:  get_char = display_text[7:0];
            4'd1:  get_char = display_text[15:8];
            4'd2:  get_char = display_text[23:16];
            4'd3:  get_char = display_text[31:24];
            4'd4:  get_char = display_text[39:32];
            4'd5:  get_char = display_text[47:40];
            4'd6:  get_char = display_text[55:48];
            4'd7:  get_char = display_text[63:56];
            4'd8:  get_char = display_text[71:64];
            4'd9:  get_char = display_text[79:72];
            4'd10: get_char = display_text[87:80];
            4'd11: get_char = display_text[95:88];
            4'd12: get_char = display_text[103:96];
            4'd13: get_char = display_text[111:104];
            4'd14: get_char = display_text[119:112];
            4'd15: get_char = display_text[127:120];
            default: get_char = CH_SPACE;
        endcase
    end
endfunction

wire [7:0] theme_id = get_char(4'd1);

wire in_console      = (pixel_x >= 10'd48)  && (pixel_x < 10'd592) && (pixel_y >= 10'd32)  && (pixel_y < 10'd448);
wire console_border  = in_console && ((pixel_x < 10'd52)  || (pixel_x >= 10'd588) || (pixel_y < 10'd36)  || (pixel_y >= 10'd444));
wire in_header       = (pixel_x >= 10'd80)  && (pixel_x < 10'd560) && (pixel_y >= 10'd56)  && (pixel_y < 10'd136);
wire header_border   = in_header && ((pixel_x < 10'd84)  || (pixel_x >= 10'd556) || (pixel_y < 10'd60)  || (pixel_y >= 10'd132));
wire in_user_card    = (pixel_x >= 10'd88)  && (pixel_x < 10'd216) && (pixel_y >= 10'd176) && (pixel_y < 10'd304);
wire user_border     = in_user_card && ((pixel_x < 10'd92)  || (pixel_x >= 10'd212) || (pixel_y < 10'd180) || (pixel_y >= 10'd300));
wire in_attempt_card = (pixel_x >= 10'd88)  && (pixel_x < 10'd216) && (pixel_y >= 10'd320) && (pixel_y < 10'd432);
wire attempt_border  = in_attempt_card && ((pixel_x < 10'd92)  || (pixel_x >= 10'd212) || (pixel_y < 10'd324) || (pixel_y >= 10'd428));
wire in_stored_card  = (pixel_x >= 10'd248) && (pixel_x < 10'd392) && (pixel_y >= 10'd176) && (pixel_y < 10'd336);
wire stored_border   = in_stored_card && ((pixel_x < 10'd252) || (pixel_x >= 10'd388) || (pixel_y < 10'd180) || (pixel_y >= 10'd332));
wire in_entered_card = (pixel_x >= 10'd416) && (pixel_x < 10'd560) && (pixel_y >= 10'd176) && (pixel_y < 10'd336);
wire entered_border  = in_entered_card && ((pixel_x < 10'd420) || (pixel_x >= 10'd556) || (pixel_y < 10'd180) || (pixel_y >= 10'd332));
wire in_compare_badge = (pixel_x >= 10'd288) && (pixel_x < 10'd520) && (pixel_y >= 10'd360) && (pixel_y < 10'd416);
wire compare_border   = in_compare_badge && ((pixel_x < 10'd292) || (pixel_x >= 10'd516) || (pixel_y < 10'd364) || (pixel_y >= 10'd412));
wire in_connector = (pixel_x >= 10'd392) && (pixel_x < 10'd416) && (pixel_y >= 10'd248) && (pixel_y < 10'd264);

reg [3:0] base_r, base_g, base_b;
reg [3:0] panel_r, panel_g, panel_b;
reg [3:0] accent_r, accent_g, accent_b;
reg [3:0] tile_r, tile_g, tile_b;
reg [3:0] alert_r, alert_g, alert_b;

always @(*) begin
    case (theme_id)
        THEME_SUCCESS: begin
            base_r = 4'h0;  base_g = 4'h3;  base_b = 4'h2;
            panel_r = 4'h1; panel_g = 4'h5; panel_b = 4'h4;
            accent_r = 4'h4; accent_g = 4'hF; accent_b = 4'h8;
            tile_r = 4'hD;  tile_g = 4'hF;  tile_b = 4'hE;
            alert_r = 4'h7; alert_g = 4'hF; alert_b = 4'h9;
        end
        THEME_FAIL: begin
            base_r = 4'h2;  base_g = 4'h1;  base_b = 4'h1;
            panel_r = 4'h4; panel_g = 4'h2; panel_b = 4'h2;
            accent_r = 4'hF; accent_g = 4'h8; accent_b = 4'h2;
            tile_r = 4'hF;  tile_g = 4'hE;  tile_b = 4'hD;
            alert_r = 4'hF; alert_g = 4'hB; alert_b = 4'h4;
        end
        THEME_LOCKOUT: begin
            base_r = 4'h2;  base_g = 4'h0;  base_b = 4'h0;
            panel_r = 4'h5; panel_g = 4'h1; panel_b = 4'h1;
            accent_r = 4'hF; accent_g = 4'h2; accent_b = 4'h3;
            tile_r = 4'hF;  tile_g = 4'hD;  tile_b = 4'hD;
            alert_r = 4'hF; alert_g = 4'h5; alert_b = 4'h5;
        end
        default: begin
            base_r = 4'h0;  base_g = 4'h1;  base_b = 4'h3;
            panel_r = 4'h1; panel_g = 4'h3; panel_b = 4'h6;
            accent_r = 4'h5; accent_g = 4'hD; accent_b = 4'hF;
            tile_r = 4'hE;  tile_g = 4'hF;  tile_b = 4'hF;
            alert_r = 4'h9; alert_g = 4'hE; alert_b = 4'hF;
        end
    endcase
end

reg [7:0] active_char;
reg [2:0] glyph_x;
reg [2:0] glyph_y;
reg glyph_active;
reg [1:0] glyph_tone;

wire [7:0] bitmap_row;
char_rom rom_inst (
    .char_addr(active_char[5:0]),
    .row(glyph_y),
    .char_bitmap(bitmap_row)
);

wire glyph_pixel_on = glyph_active && bitmap_row[7 - glyph_x];

always @(*) begin
    active_char = CH_SPACE;
    glyph_x = 3'd0;
    glyph_y = 3'd0;
    glyph_active = 1'b0;
    glyph_tone = TONE_STATUS;

    // Header status code: four large characters.
    if ((pixel_x >= 10'd216) && (pixel_x < 10'd344) && (pixel_y >= 10'd76) && (pixel_y < 10'd108)) begin
        active_char = get_char(4'd15 - ((pixel_x - 10'd216) >> 5));
        glyph_x = (pixel_x - 10'd216) >> 2;
        glyph_y = (pixel_y - 10'd76) >> 2;
        glyph_active = 1'b1;
        glyph_tone = TONE_STATUS;
    end
    // Accent code below the status line.
    else if ((pixel_x >= 10'd272) && (pixel_x < 10'd336) && (pixel_y >= 10'd112) && (pixel_y < 10'd128)) begin
        active_char = get_char(4'd11 - ((pixel_x - 10'd272) >> 4));
        glyph_x = (pixel_x - 10'd272) >> 1;
        glyph_y = (pixel_y - 10'd112) >> 1;
        glyph_active = 1'b1;
        glyph_tone = TONE_ALERT;
    end
    // User ID tile.
    else if ((pixel_x >= 10'd120) && (pixel_x < 10'd184) && (pixel_y >= 10'd208) && (pixel_y < 10'd272)) begin
        active_char = get_char(4'd7);
        glyph_x = (pixel_x - 10'd120) >> 3;
        glyph_y = (pixel_y - 10'd208) >> 3;
        glyph_active = 1'b1;
        glyph_tone = TONE_TILE;
    end
    // Attempts-left tile.
    else if ((pixel_x >= 10'd120) && (pixel_x < 10'd184) && (pixel_y >= 10'd344) && (pixel_y < 10'd408)) begin
        active_char = get_char(4'd4);
        glyph_x = (pixel_x - 10'd120) >> 3;
        glyph_y = (pixel_y - 10'd344) >> 3;
        glyph_active = 1'b1;
        glyph_tone = TONE_TILE;
    end
    // Stored password tile.
    else if ((pixel_x >= 10'd288) && (pixel_x < 10'd352) && (pixel_y >= 10'd224) && (pixel_y < 10'd288)) begin
        active_char = get_char(4'd6);
        glyph_x = (pixel_x - 10'd288) >> 3;
        glyph_y = (pixel_y - 10'd224) >> 3;
        glyph_active = 1'b1;
        glyph_tone = TONE_TILE;
    end
    // Entered password tile.
    else if ((pixel_x >= 10'd456) && (pixel_x < 10'd520) && (pixel_y >= 10'd224) && (pixel_y < 10'd288)) begin
        active_char = get_char(4'd5);
        glyph_x = (pixel_x - 10'd456) >> 3;
        glyph_y = (pixel_y - 10'd224) >> 3;
        glyph_active = 1'b1;
        glyph_tone = TONE_TILE;
    end
    // Compare badge in the footer.
    else if ((pixel_x >= 10'd340) && (pixel_x < 10'd372) && (pixel_y >= 10'd372) && (pixel_y < 10'd404)) begin
        active_char = get_char(4'd2);
        glyph_x = (pixel_x - 10'd340) >> 2;
        glyph_y = (pixel_y - 10'd372) >> 2;
        glyph_active = 1'b1;
        glyph_tone = TONE_ALERT;
    end
    // ALU result badge.
    else if ((pixel_x >= 10'd436) && (pixel_x < 10'd468) && (pixel_y >= 10'd372) && (pixel_y < 10'd404)) begin
        active_char = get_char(4'd3);
        glyph_x = (pixel_x - 10'd436) >> 2;
        glyph_y = (pixel_y - 10'd372) >> 2;
        glyph_active = 1'b1;
        glyph_tone = TONE_STATUS;
    end
end

always @(*) begin
    if (!valid_pixel) begin
        red = 4'h0;
        green = 4'h0;
        blue = 4'h0;
    end
    else if (glyph_pixel_on) begin
        case (glyph_tone)
            TONE_TILE: begin
                red = tile_r;
                green = tile_g;
                blue = tile_b;
            end
            TONE_ALERT: begin
                red = alert_r;
                green = alert_g;
                blue = alert_b;
            end
            default: begin
                red = 4'hF;
                green = 4'hF;
                blue = 4'hF;
            end
        endcase
    end
    else if (console_border || header_border || user_border || attempt_border || stored_border || entered_border || compare_border) begin
        red = accent_r;
        green = accent_g;
        blue = accent_b;
    end
    else if (in_header) begin
        red = accent_r >> 1;
        green = accent_g >> 1;
        blue = accent_b >> 1;
    end
    else if (in_user_card || in_attempt_card || in_stored_card || in_entered_card || in_compare_badge) begin
        red = panel_r;
        green = panel_g;
        blue = panel_b;
    end
    else if (in_connector) begin
        red = accent_r;
        green = accent_g;
        blue = accent_b;
    end
    else if (in_console) begin
        red = base_r + {3'b000, pixel_y[5]};
        green = base_g + {3'b000, pixel_y[6]};
        blue = base_b + {3'b000, pixel_x[6]};
    end
    else begin
        red = base_r >> 1;
        green = base_g >> 1;
        blue = base_b >> 1;
    end
end

endmodule
