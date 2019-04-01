`timescale 1ns/1ps

`include "define.vh"

module neuron_tb();

    logic [`receptive_field-1:0] spikes_in;
    logic [`receptive_field-1:0][`WBITS-1:0] weights;
    logic spikes_out;

    neuron N0(.spikes_in, .weights, .spikes_out);
    
    int i = 0;
    int j = 0;
    initial begin
        spikes_in = 8'b0000_0000;
        weights = {`receptive_field{`WBITS'b0}};
        #5;
        for(i=0; i<5; i++) begin
            for(j=0; j<5; j++) begin
                $display("spikes: %b    weights: %b    sum: %d     threshold: %d    spikes_out:%d",
                         spikes_in, weights, N0.sum, `THRESHOLD, spikes_out);
                #5;
                weights = weights + (1'b1 << $urandom_range((`WBITS)*(`receptive_field)-1,0));
            end
            spikes_in = spikes_in + (1'b1 << $urandom_range(`receptive_field-1,0));
        end
    end

endmodule