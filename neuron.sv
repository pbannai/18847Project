`timescale 1ns/1ps
`default_nettype none
`include "internal_defines.vh"

//Accumulator

module neuron(
    input  logic [`num_spikes-1:0] spikes_in,
    input  logic [`num_spikes-1:0][`WBITS-1:0] weights,
    output logic spikes_out);

    logic [3:0] sum;
    int i;
    always @* begin
        sum = 'd0;
        for(i=0; i<`num_spikes; i++) begin
            sum = sum + spikes_in[i] * weights[i];
        end
    end

    assign spikes_out = (sum > `THRESHOLD) ? 1'b1 : 1'b0;

endmodule

