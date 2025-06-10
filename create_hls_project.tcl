# Create HLS project
open_project snn_accelerator_hls
set_top snn_controller

# Add source files
add_files src/snn_controller.cpp
add_files src/snn_types.h

# Add testbench
add_files -tb tb_snn_controller.cpp

# Create solution
open_solution "solution1"
set_part {xc7a35tfgg484-2}
create_clock -period 10 -name default

# Run C simulation
csim_design

# Run synthesis
csynth_design

# Export RTL as IP
export_design -format ip_catalog -description "SNN Controller IP" -version "1.0"
