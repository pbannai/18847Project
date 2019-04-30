`timescale 1ns/1ps
`default_nettype none
`include "internal_defines.vh"

module layer_tb();

    logic [`num_spikes-1:0] spikes_in;
    logic [`num_spikes-1:0][`WBITS-1:0] weights;
    logic spikes_out;
    logic clk, rst_l;

    integer generated_spikes_fd, testing_fd;
    logic  [`num_spikes - 1:0][$clog2(`time_period):0]spike_times;
    int i;

    layer L0 (.clk(clk),
              .rst_l(rst_l),
              .time_val(),
              .spike_times(),
              .output_spike_time());

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        generated_spikes_fd = $fopen("training_spikes.txt", "r");
        testing_fd = $fopen("testing.txt", "w");
        while(! $feof(generated_spikes_fd))begin
            // fill spikes into spike_times
            for(i=0; i < `num_spikes; i++)begin
                $fscanf(generated_spikes_fd, "%d\n", spike_times[i]);            
                $fdisplay(testing_fd, "%d", spike_times);
                $display("value of spikes[%1d]: %b", i, spike_times[i]);
                repeat (8) @(posedge clk);
            end

        end
        $fclose(generated_spikes_fd);
        #100;

        $finish;
    end
endmodule
