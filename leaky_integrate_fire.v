// Simulate the LIF neuron model
// tau_m * dV/dt = -(V-E_L) + I/g_L

module leaky_integrate_fire
(
    clk, reset_n,
    spike_in, weight, memb_potential, threshold, leak_value, tref,
    V_out, spike_out
    );
    /*
    INPUT
    clk: clock
    reset_n: reset negated
    spike_in: input spike, 8 inputs
    weight: synaptic weight, int8, 8 inputs
    threshold: threshold potential [mV], int8
    leak_value: leak value [mV], uint8
    tref: refractory period [ms], uint4

    OUTPUT
    V_out: membrane potential, int8
    spike_out: output spike
    */

    input               clk, reset_n;
    input       [7:0]   spike_in;
    input       [63:0]  weight;
    input       [7:0]   memb_potential;
    input       [7:0]   threshold;
    input       [7:0]   leak_value;
    input       [3:0]   tref;

    output      [7:0]   V_out;
    output reg          spike_out;

    reg         [3:0]   tr = 0;
    reg         [7:0]   voltage;

    wire        [7:0]   I_int;  // integrate current
    wire        [7:0]   memb_potential_int; // integrate membrane potential
    wire        [7:0]   leak_and_int_potential; // leaked current and integrated potential

    wire                gnd = 1'b0;

    // integrate current
    cla8_8 uut_cla8_8 (
        .a(weight[7:0]&spike_in[0]), .b(weight[15:8]&spike_in[1]), .c(weight[23:16]&spike_in[2]), .d(weight[31:24]&spike_in[3]),
        .e(weight[39:32]&spike_in[4]), .f(weight[47:40]&spike_in[5]), .g(weight[55:48]&spike_in[6]), .h(weight[63:56]&spike_in[7]),
        .ci(1'b0), .co(gnd), .s(I_int)
    );

    // integrate membrane potential and current

    // leak current
    assign leak_and_int_potential = memb_potential_int - leak_value;

    always @(posedge clk or negedge reset_n)
    begin
        if (~reset_n) begin
            voltage <= 8'b0;
            spike_out <= 1'b0;
            tr <= 4'b0;
        end

        else begin
            // check if in refractory period
            if (tr > 0) begin
                spike_out <= 1'b0;
                voltage = 8'b0;
                tr <= tr - 4'b1;
            end
            else if (leak_and_int_potential >= threshold) begin   // leak_and_int_potential >= threshold
                spike_out <= 1'b1;  
                voltage = 8'b0;
                tr <= tref;     // refractory period
            end
            else begin
                spike_out <= 1'b0;
            end
        end
    end
    
    assign V_out = voltage;

endmodule
