`timescale 1ns/1ps
//`default_nettype none
`include "internal_defines.vh"

//Accumulator

module neuron(
    input  logic [`num_spikes-1:0] spikes_in,
    input  logic [`num_spikes-1:0][`WBITS-1:0] weights,
    output logic spikes_out);

    logic [8:0] sum;
    int i;
    always @* begin
        sum = 'd0;
        for(i=0; i<`num_spikes; i++) begin
	    if(spikes_in[i] == 1'b1)begin
                sum = sum + $unsigned(weights[i]);
	    end
        end
    end

    assign spikes_out = (sum >= `THRESHOLD) ? 1'b1 : 1'b0;

endmodule

