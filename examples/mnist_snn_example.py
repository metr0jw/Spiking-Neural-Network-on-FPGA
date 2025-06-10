# examples/mnist_snn_example.py
import numpy as np
from snn_accelerator import SNNNetwork
import matplotlib.pyplot as plt

def encode_mnist_to_spikes(image, duration=0.1, max_rate=100):
    """Convert MNIST image to spike times"""
    spike_times = {}
    flat_image = image.flatten()
    
    for i, pixel in enumerate(flat_image):
        if pixel > 0:
            rate = (pixel / 255.0) * max_rate
            n_spikes = np.random.poisson(rate * duration)
            times = np.sort(np.random.uniform(0, duration, n_spikes))
            spike_times[i] = times.tolist()
    
    return spike_times

# Initialize network
network = SNNNetwork(fpga_ip="192.168.1.100")
network.connect()

# Create a 3-layer feedforward network
# 784 input (28x28 MNIST) -> 100 hidden -> 10 output
network.create_network("feedforward", layer_sizes=[784, 100, 10])

# Define neuron groups
network.add_neuron_group("input", list(range(784)))
network.add_neuron_group("hidden", list(range(784, 884)))
network.add_neuron_group("output", list(range(884, 894)))

# Set neuron parameters
network.fpga.set_neuron_parameters(
    leak_rate=10,
    refractory_period=20,
    threshold=1000
)

# Load MNIST sample (you'd load real data here)
sample_image = np.random.rand(28, 28) * 255

# Encode to spikes
input_spikes = encode_mnist_to_spikes(sample_image)

# Run simulation
output_spikes = network.run_simulation(duration=0.1, input_pattern=input_spikes)

# Analyze results
stats = network.get_spike_statistics(output_spikes)
print(f"Total output spikes: {stats['total_spikes']}")
print(f"Active neurons: {stats['active_neurons']}")

# Plot output neuron activity
output_neuron_spikes = [s for s in output_spikes if s.neuron_id >= 884]
plt.figure(figsize=(10, 6))
for spike in output_neuron_spikes:
    plt.scatter(spike.timestamp/1000, spike.neuron_id - 884, c='black', s=1)
plt.xlabel('Time (ms)')
plt.ylabel('Output Neuron')
plt.title('Output Layer Spike Raster')
plt.show()

# Disconnect
network.disconnect()
