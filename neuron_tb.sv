`timescale 1ns/1ps
`default_nettype none
`include "internal_defines.vh"

module neuron_tb();
    int i = 0;
    int j = 0;
    initial begin
        spikes_in = 8'b0000_0000;
        weights = {`num_spikes{`WBITS'b0}};
        #5;
        for(i=0; i<5; i++) begin
            for(j=0; j<5; j++) begin
                $display("spikes: %b    weights: %b    sum: %d     threshold: %d    spikes_out:%d",
                         spikes_in, weights, N0.sum, `THRESHOLD, spikes_out);
                #5;
                weights = weights + (1'b1 << $urandom_range((`WBITS)*(`num_spikes)-1,0));
            end
            spikes_in = spikes_in + (1'b1 << $urandom_range(`num_spikes-1,0));
        end
    end
endmodule
