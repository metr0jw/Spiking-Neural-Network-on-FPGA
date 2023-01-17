`timescale 1ns / 100ps

module tb_leaky_integrate_fire;
    reg             clk, reset_n;
    reg             spike_in_0, spike_in_1, spike_in_2, spike_in_3, spike_in_4, spike_in_5, spike_in_6, spike_in_7;
    reg     [7:0]   weight_0, weight_1, weight_2, weight_3, weight_4, weight_5, weight_6, weight_7;
    reg     [7:0]   memb_potential;
    reg     [7:0]   threshold;
    reg     [7:0]   leak_value;
    reg     [3:0]   tref;

    wire    [7:0]   V_out;
    wire            spike_out;

    parameter STEP = 10;

    leaky_integrate_fire uut (
        .clk(clk), .reset_n(reset_n),
        .spike_in({spike_in_7, spike_in_6, spike_in_5, spike_in_4, spike_in_3, spike_in_2, spike_in_1, spike_in_0}),
        .weight({weight_7, weight_6, weight_5, weight_4, weight_3, weight_2, weight_1, weight_0}),
        .memb_potential(memb_potential), .threshold(threshold), .leak_value(leak_value), .tref(tref),
        .V_out(V_out), .spike_out(spike_out)
    );

    always #(STEP/2) clk = ~clk;
    initial begin

        $finish;
    end

endmodule
