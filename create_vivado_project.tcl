# Create Vivado project
create_project snn_accelerator ./snn_accelerator -part xc7a35tfgg484-2

# Add Verilog sources
add_files {
    ./rtl/snn_accelerator_top.v
    ./rtl/lif_neuron_array.v
    ./rtl/ethernet_spike_interface.v
}

# Add HLS IP repository
set_property ip_repo_paths ./snn_accelerator_hls/solution1/impl/ip [current_project]
update_ip_catalog

# Create block design (optional, for AXI connections)
create_bd_design "snn_system"

# Add HLS IP to block design
create_bd_cell -type ip -vlnv xilinx.com:hls:snn_controller:1.0 snn_controller_0

# Add constraints file
add_files -fileset constrs_1 ./constraints/ax7035b.xdc

# Run synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Run implementation
launch_runs impl_1 -jobs 4
wait_on_run impl_1

# Generate bitstream
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
