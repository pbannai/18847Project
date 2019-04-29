`timescale 1ns/1ps
 `default_nettype none
`include "internal_defines.vh"

module neuron_tb();

    logic [`num_spikes-1:0] spikes_in;
    logic [`num_spikes-1:0][`WBITS-1:0] weights;
    logic spikes_out;
    logic clk, rst_l;
    neuron N0(.spikes_in, .weights, .spikes_out);

    integer generated_spikes, testing;
    reg  [7:0][3:0]spike_times;
    int fill_spikes;
    initial begin
        generated_spikes = $fopen("training_spikes.txt", "r");
        testing = $fopen("testing.txt", "w");
        while(! $feof(generated_spikes))begin
            for(fill_spikes = 0; fill_spikes < `num_spikes; fill_spikes++)begin
                $fscanf(generated_spikes, "%d\n", spike_times[fill_spikes]);            
                $fdisplay(testing, "%d", spike_times);
                $display("value of spikes[%1d]: %b", fill_spikes, spike_times[fill_spikes]);
                #10;
            end

        end
        $fclose(generated_spikes);
        #100;


        $finish;
    end

/*
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
*/
endmodule
