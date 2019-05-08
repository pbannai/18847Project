`timescale 1ns/1ps
`default_nettype none
`include "internal_defines.vh"

module layer_tb();

    integer testing_spikes_fd, training_spikes_fd, testing_results_fd;
    int i;
    logic [`num_spikes-1:0] spikes_in;
    logic [`num_spikes-1:0][`WBITS-1:0] weights;
    logic spikes_out;
    logic clk, rst_l;


    logic  [`num_spikes - 1:0][$clog2(`time_period):0]spike_times;

    logic [$clog2(`neurons_per_layer)-1:0] winning_neuron;
    logic [$clog2(`time_period):0] time_val;
    logic [$clog2(`time_period):0] output_spike_time;
    layer L0 (.clk(clk),
              .rst_l(rst_l),
              .time_val(time_val),
              .spike_times(spike_times),
              .output_spike_time(output_spike_time),
              .winning_neuron(winning_neuron)
             );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        rst_l = 0;
        #9;
        rst_l = 1;
        training_spikes_fd = $fopen("training_spikes.csv", "r");
        testing_spikes_fd = $fopen("testing_spikes.csv", "r");
	    testing_results_fd = $fopen("testing_results.csv", "w");
        while(! $feof(training_spikes_fd))begin
            // fill spikes into spike_times
            for(i=0; i < `num_spikes; i++)begin
                $fscanf(training_spikes_fd, "%d\n", spike_times[i]);            
                $fdisplay(testing_spikes_fd, "%d", spike_times);
                $display("value of spikes[%1d]: %b", i, spike_times[i]);
            end
            repeat (8) @(posedge clk);
        end
        $fclose(training_spikes_fd);
        #`time_period;

        $finish;
    end
endmodule
