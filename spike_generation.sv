`timescale 1ns/1ps

`include "define.vh"

module spike_generation(
    input logic should_spike,
    input logic [$clog2(`time_period)-1:0] time_val,
    input logic [$clog2(`time_period)-1:0] spike_time,
    output logic spike_val

);

    always_comb begin
        if($unsigned(spike_time) > $unsigned(time_val) && should_spike_l == 1'b1)begin
            spike_val = should_spike;
        end else begin
            spike_val = 1'b0;
        end
    end

endmodule
