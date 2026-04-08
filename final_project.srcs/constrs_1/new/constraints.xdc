## Clock (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Switches
set_property PACKAGE_PIN V17 [get_ports {switch_input[0]}]
set_property PACKAGE_PIN V16 [get_ports {switch_input[1]}]
set_property PACKAGE_PIN W16 [get_ports {switch_input[2]}]
set_property PACKAGE_PIN W17 [get_ports {switch_input[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switch_input[*]}]

## Buttons
set_property PACKAGE_PIN U18 [get_ports reset]
set_property PACKAGE_PIN T18 [get_ports enter]
set_property PACKAGE_PIN W19 [get_ports load]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports enter]
set_property IOSTANDARD LVCMOS33 [get_ports load]

## LED
set_property PACKAGE_PIN U16 [get_ports unlock_led]
set_property IOSTANDARD LVCMOS33 [get_ports unlock_led]