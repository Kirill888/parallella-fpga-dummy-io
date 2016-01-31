open_project my_mult_axis
set_top my_mult_axis
add_files src/my_mult.cpp
add_files src/my_mult.h
add_files -tb src/my_mult_tb.cpp


open_solution "axis"
set_part {xc7z010clg400-1}
create_clock -period 10 -name default
set_directive_interface -mode ap_ctrl_none  "my_mult_axis"
set_directive_interface -mode axis -depth 1 "my_mult_axis" S_AXIS
set_directive_interface -mode axis -depth 1 "my_mult_axis" D_AXIS



csim_design
csynth_design
cosim_design

export_design -format ip_catalog -description "Example IP: AXIS multiplier" -vendor "k88k"

exit 0
