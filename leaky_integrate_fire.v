// Simulate the LIF neuron model
// tau_m * dV/dt = -(V-E_L) + I/g_L

module leaky_integrate_fire
(
    clk, reset_n,
    spike_in, weight, memb_potential_in, threshold, leak_value, tref,
    memb_potential_out, spike_out
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
    input       [7:0]   memb_potential_in;
    input       [7:0]   threshold;
    input       [7:0]   leak_value;
    input       [3:0]   tref;

    output      [7:0]   memb_potential_out;
    output reg          spike_out;

    reg         [3:0]   tr = 0;
    reg         [7:0]   voltage;

    wire        [7:0]   memb_potential_integrate; // integrate membrane potential
    wire        [7:0]   synaptic_integration;   // integrate synaptic current
    wire        [7:0]   leak_and_int_potential; // leaked current and integrated potential
    wire                underflow;

    wire        [7:0]   spike_bit_extend[0:7];

    wire                gnd = 1'b0;

    // bit extend spike_in
    bit_extender_1to8_8 uut_bit_extender_1to8_8 (
        .x1(spike_in[0]), .x2(spike_in[1]), .x3(spike_in[2]), .x4(spike_in[3]),
        .x5(spike_in[4]), .x6(spike_in[5]), .x7(spike_in[6]), .x8(spike_in[7]),
        .y1(spike_bit_extend[0][7:0]), .y2(spike_bit_extend[1][7:0]), .y3(spike_bit_extend[2][7:0]), .y4(spike_bit_extend[3][7:0]),
        .y5(spike_bit_extend[4][7:0]), .y6(spike_bit_extend[5][7:0]), .y7(spike_bit_extend[6][7:0]), .y8(spike_bit_extend[7][7:0])
    );

    // integrate current
    cla8_8 uut_cla8_8 (
        .a(weight[7:0] & spike_bit_extend[0]), .b(weight[15:8] & spike_bit_extend[1]),
        .c(weight[23:16] & spike_bit_extend[2]), .d(weight[31:24] & spike_bit_extend[3]),
        .e(weight[39:32] & spike_bit_extend[4]), .f(weight[47:40] & spike_bit_extend[5]),
        .g(weight[55:48] & spike_bit_extend[6]), .h(weight[63:56] & spike_bit_extend[7]),
        .ci(1'b0), .co(gnd), .s(memb_potential_integrate)
    );

    // integrate membrane potential and current
    cla8 uut_cla8 (
        .a(memb_potential_in), .b(memb_potential_integrate),
        .ci(1'b0), .co(gnd), .s(synaptic_integration)
    );

    // leak current
    assign leak_and_int_potential = synaptic_integration - leak_value;
    assign underflow = synaptic_integration < leak_value;

    always @(posedge clk or negedge reset_n)
    begin
        if (~reset_n) begin
            spike_out <= 1'b0;
            voltage <= 8'b0;
            tr <= 4'b0;
        end

        else begin
            // check if in refractory period
            if (tr > 0) begin
                spike_out <= 1'b0;
                voltage = 8'b0;
                tr <= tr - 4'b1;
            end
            else if (underflow) begin
                spike_out <= 1'b0;
                voltage <= 8'b0;
            end
            else if (leak_and_int_potential >= threshold) begin   // leak_and_int_potential >= threshold
                spike_out <= 1'b1;  
                voltage = 8'b0;
                tr <= tref;     // refractory period
            end
            else begin
                spike_out <= 1'b0;
                voltage <= leak_and_int_potential;
            end
        end
    end
    
    assign memb_potential_out = voltage;

endmodule
