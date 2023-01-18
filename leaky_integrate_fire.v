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

    wire        [15:0]   memb_potential_integrate; // integrate membrane potential
    wire        [15:0]   synaptic_integration;   // integrate synaptic current
    wire        [15:0]   leak_and_int_potential; // leaked current and integrated potential
    wire                underflow;

    wire        [7:0]   spike_bit_extend[0:7];
    wire        [7:0]   spike_and_weight[0:7];

    wire                gnd = 1'b0;

    // bit extend spike_in
    bit_extender_1to8_8 uut_bit_extender_1to8_8 (
        .x1(spike_in[0]), .x2(spike_in[1]), .x3(spike_in[2]), .x4(spike_in[3]),
        .x5(spike_in[4]), .x6(spike_in[5]), .x7(spike_in[6]), .x8(spike_in[7]),
        .y1(spike_bit_extend[0][7:0]), .y2(spike_bit_extend[1][7:0]), .y3(spike_bit_extend[2][7:0]), .y4(spike_bit_extend[3][7:0]),
        .y5(spike_bit_extend[4][7:0]), .y6(spike_bit_extend[5][7:0]), .y7(spike_bit_extend[6][7:0]), .y8(spike_bit_extend[7][7:0])
    );

    // multiply spike_in and weight
    _and2_8bits uut_and2_8bits (
        .a(spike_bit_extend[0][7:0]), .b(weight[7:0]),
        .y(spike_and_weight[0][7:0])
    );
    _and2_8bits uut_and2_8bits_1 (
        .a(spike_bit_extend[1][7:0]), .b(weight[15:8]),
        .y(spike_and_weight[1][7:0])
    );
    _and2_8bits uut_and2_8bits_2 (
        .a(spike_bit_extend[2][7:0]), .b(weight[23:16]),
        .y(spike_and_weight[2][7:0])
    );
    _and2_8bits uut_and2_8bits_3 (
        .a(spike_bit_extend[3][7:0]), .b(weight[31:24]),
        .y(spike_and_weight[3][7:0])
    );
    _and2_8bits uut_and2_8bits_4 (
        .a(spike_bit_extend[4][7:0]), .b(weight[39:32]),
        .y(spike_and_weight[4][7:0])
    );
    _and2_8bits uut_and2_8bits_5 (
        .a(spike_bit_extend[5][7:0]), .b(weight[47:40]),
        .y(spike_and_weight[5][7:0])
    );
    _and2_8bits uut_and2_8bits_6 (
        .a(spike_bit_extend[6][7:0]), .b(weight[55:48]),
        .y(spike_and_weight[6][7:0])
    );
    _and2_8bits uut_and2_8bits_7 (
        .a(spike_bit_extend[7][7:0]), .b(weight[63:56]),
        .y(spike_and_weight[7][7:0])
    );

    // integrate current
    cla16_8 uut_cla16_8 (
        .a({8'b0, spike_and_weight[0]}), .b({8'b0, spike_and_weight[1]}),
        .c({8'b0, spike_and_weight[2]}), .d({8'b0, spike_and_weight[3]}),
        .e({8'b0, spike_and_weight[4]}), .f({8'b0, spike_and_weight[5]}),
        .g({8'b0, spike_and_weight[6]}), .h({8'b0, spike_and_weight[7]}),
        .ci(1'b0), .s(memb_potential_integrate), .co(gnd)
    );

    // integrate membrane potential and current
    cla16 uut_cla16 (
        .a({8'b0, memb_potential_in}), .b(memb_potential_integrate),
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
                tr <= tr - 4'b1;
                voltage = 8'b0;
            end
            else if (underflow) begin
                spike_out <= 1'b0;
                voltage <= 8'b0;
            end
            else if (leak_and_int_potential >= threshold) begin   // leak_and_int_potential >= threshold
                spike_out <= 1'b1;  
                tr <= tref;     // refractory period
                voltage = 8'b0;
            end
            else begin
                spike_out <= 1'b0;
                voltage <= leak_and_int_potential[7:0];
            end
        end
    end
    
    assign memb_potential_out = voltage;

endmodule
