# Master Makefile for SNN Accelerator
.PHONY: all clean hls vivado software

all: hls vivado software

hls:
	cd hls && vitis_hls -f scripts/create_project.tcl

vivado: hls
	cd scripts && vivado -mode batch -source create_vivado_project.tcl

software:
	cd software/cpp && mkdir -p build && cd build && cmake .. && make
	cd software/python && pip install -e .

program:
	cd scripts && vivado -mode batch -source program_fpga.tcl

clean:
	rm -rf build/
	cd hls && rm -rf solution*
	find . -name "*.log" -delete
	find . -name "*.jou" -delete

test:
	cd hdl/tb && vsim -do run_all_tests.do
	cd software/python && pytest tests/
