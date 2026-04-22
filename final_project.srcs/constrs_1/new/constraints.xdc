## Clock (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Switches for Password Input (SW0-SW3)
set_property PACKAGE_PIN V17 [get_ports {switch_input[0]}]
set_property PACKAGE_PIN V16 [get_ports {switch_input[1]}]
set_property PACKAGE_PIN W16 [get_ports {switch_input[2]}]
set_property PACKAGE_PIN W17 [get_ports {switch_input[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switch_input[*]}]

## Switches for User ID (SW4-SW7)
set_property PACKAGE_PIN W15 [get_ports {user_id[0]}]
set_property PACKAGE_PIN V15 [get_ports {user_id[1]}]
set_property PACKAGE_PIN W14 [get_ports {user_id[2]}]
set_property PACKAGE_PIN W13 [get_ports {user_id[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {user_id[*]}]

## Buttons
set_property PACKAGE_PIN U18 [get_ports reset]
set_property PACKAGE_PIN T18 [get_ports enter]
set_property PACKAGE_PIN W19 [get_ports load]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports enter]
set_property IOSTANDARD LVCMOS33 [get_ports load]

## LEDs
set_property PACKAGE_PIN U16 [get_ports unlock_led]
set_property PACKAGE_PIN U19 [get_ports lockout_led]
set_property IOSTANDARD LVCMOS33 [get_ports unlock_led]
set_property IOSTANDARD LVCMOS33 [get_ports lockout_led]

## Seven Segment Display (Common Anode)
## Segments: CA, CB, CC, CD, CE, CF, CG
set_property PACKAGE_PIN W7 [get_ports {seven_segment[0]}]
set_property PACKAGE_PIN W6 [get_ports {seven_segment[1]}]
set_property PACKAGE_PIN U8 [get_ports {seven_segment[2]}]
set_property PACKAGE_PIN V8 [get_ports {seven_segment[3]}]
set_property PACKAGE_PIN U5 [get_ports {seven_segment[4]}]
set_property PACKAGE_PIN V5 [get_ports {seven_segment[5]}]
set_property PACKAGE_PIN U7 [get_ports {seven_segment[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[*]}]

## Seven Segment Display Anode Enable (AN0-AN3)
set_property PACKAGE_PIN W4 [get_ports {anode_enable[0]}]
set_property PACKAGE_PIN V4 [get_ports {anode_enable[1]}]
set_property PACKAGE_PIN U4 [get_ports {anode_enable[2]}]
set_property PACKAGE_PIN U2 [get_ports {anode_enable[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode_enable[*]}]

## VGA Port Output (Basys 3)
set_property PACKAGE_PIN G19 [get_ports vga_red[0]]
set_property PACKAGE_PIN H19 [get_ports vga_red[1]]
set_property PACKAGE_PIN J19 [get_ports vga_red[2]]
set_property PACKAGE_PIN N19 [get_ports vga_red[3]]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[*]}]

set_property PACKAGE_PIN J17 [get_ports vga_green[0]]
set_property PACKAGE_PIN H17 [get_ports vga_green[1]]
set_property PACKAGE_PIN G17 [get_ports vga_green[2]]
set_property PACKAGE_PIN D17 [get_ports vga_green[3]]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[*]}]

set_property PACKAGE_PIN N18 [get_ports vga_blue[0]]
set_property PACKAGE_PIN L18 [get_ports vga_blue[1]]
set_property PACKAGE_PIN K18 [get_ports vga_blue[2]]
set_property PACKAGE_PIN J18 [get_ports vga_blue[3]]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[*]}]

set_property PACKAGE_PIN P19 [get_ports vga_hsync]
set_property PACKAGE_PIN R19 [get_ports vga_vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]

## PS/2 Keyboard Port (Basys 3)
set_property PACKAGE_PIN C17 [get_ports ps2_clk]
set_property PACKAGE_PIN B17 [get_ports ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_data]