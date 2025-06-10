# Spiking-Neural-Network-on-FPGA
## Development environment
- Vivado 2023.1, Vitis HLS 2023.1
- PYNQ-Z2 (Xilinx Zynq-7000)

## Description
This project is a Spiking Neural Network(SNN) implementation on FPGA. The SNN is composed of 3 layers: input, hidden, and output. The input layer is composed of 784 neurons, the hidden layer is composed of 100 neurons, and the output layer is composed of 10 neurons. The input layer is connected to the hidden layer, and the hidden layer is connected to the output layer.

## To-Do
- [ ] Implement Spike Timing Dependent Plasticity for weight update
- [ ] Implement inhibitory neuron
- [ ] Weight loading from file

## How to use
### NOT IMPLEMENTED YET
### 1. Clone this repository
```bash
$ git clone https://github.com/metr0jw/Spiking-Neural-Network-on-FPGA.git
```
### 2. Open the project via Quartus
### 3. Compile the project
### 4. Download the bitstream to FPGA
## Contribute
### 1. Fork it
### 2. Create your feature branch
### 3. Commit your changes
### 4. Push to the branch
### 5. Create a new Pull Request

## License
[MIT License](LICENSE)

## Author
[Jiwoon Lee](https://github.com/metr0jw)
