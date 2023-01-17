`timescale 1ns / 1ps

module tb_leaky_integrate_fire;
    reg             clk, reset_n, stop;
    reg     [7:0]   current;
    wire    [7:0]   v_out;
    parameter       STEP = 10;

    leaky_integrate_fire uut (
        .clk(clk), .reset_n(reset_n),
        .current(current), .stop(stop),
        .v_out(v_out);
    );

    always #(STEP/2) clk = ~clk;
    initial begin
        reset_n = 1;
        #STEP reset_n = 0, stop = 0;
        #STEP 

        $finish;
    end

endmodule
