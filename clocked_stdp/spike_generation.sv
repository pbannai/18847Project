`timescale 1ns/1ps
// `default_nettype none
`include "internal_defines.vh"

module spike_generation(
    input logic should_spike,
    input logic [`log_time_period:0] time_val,
    input logic [`log_testing_period-1:0] spike_time,
    output logic spike_val

);

    always_comb begin
        if(($unsigned(spike_time) <= $unsigned(time_val)) && should_spike == 1'b0)begin
            spike_val = 1'b1;
        end else begin
            spike_val = 1'b0;
        end
    end

endmodule
