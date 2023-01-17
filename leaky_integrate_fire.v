// Simulate the LIF neuron model
// tau_m * dV/dt = -(V-E_L) + I/g_L

module leaky_integrate_fire
(
    clk, reset_n,
    current, stop,
    V_out, V_out_next, is_spike,
    );
    /*
    INPUT
    clk: clock
    reset_n: reset negated
    current: input current
    stop: use a current pulse if True
    V_out_prev: previous membrane potential

    OUTPUT
    V_out: membrane potential
    V_out_next: next membrane potential
    */
    input               clk, reset_n;
    input       [7:0]   current;
    input               stop;
    input       [7:0]   V_out_prev;
    output reg  [7:0]   V_out, V_out_next;
    output reg          is_spike;

    reg         [7:0]   tr = 0;
    reg         [7:0]   dv = 0;

    /*
    V_th: threshold potential
    V_reset: reset potential
    tau_m: membrane time constant
    g_L: leak conductance
    V_init: initial potential
    E_L: resting potential
    tref: refractory period
    */
    parameter           V_th = -55;
    parameter           V_reset = -75;
    parameter           tau_m = 10;
    parameter           g_L = 10;
    parameter           V_init = -75;
    parameter           E_L = -75;
    parameter           tref = 2;
    parameter           time_scale = 1000000;

    always @(posedge clk or posedge reset_n)
    begin
        if (reset_n) begin
            V_out <= V_init;
            V_out_next <= V_init;
            is_spike <= 0;
            tr <= 0;
            dv <= 0;
        end

        else begin
            // check if in refractory period
            if (tr > 0) begin
                is_spike <= 0;
                V_out <= V_reset;
                tr <= tr - 1;
            end
            else if(V_out >= V_th) begin
                is_spike <= 1;  // memb_potential >= V_th
                V_out <= V_reset;
                tr <= tref;     // refractory period
            end

            dv <= V_out - V_out_prev;
            V_out_next <= V_out + dv;
        end
    end
endmodule
