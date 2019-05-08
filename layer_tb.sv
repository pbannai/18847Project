`timescale 1ns/1ps
`default_nettype none
`include "internal_defines.vh"

module layer_tb();

    integer testing_spikes_fd, training_spikes_fd, testing_results_fd;
    int i;

    logic clk, rst_l, training;


    logic  [`num_spikes - 1:0][`log_time_period:0] spike_times;

    logic [`log_neurons_per_layer:0] winning_neuron;
    logic [`log_time_period:0] time_val, time_val_next;
    logic [`log_time_period:0] output_spike_time;
    layer L0 (.clk(clk),
              .training(training),
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
    
    always @(posedge clk or negedge rst_l)begin
        if(rst_l == 1'b0)begin
            time_val <= '0;
        end else begin
            time_val <= time_val_next;
        end
    end
    
    always_comb begin
        if(time_val == `time_period - 1)begin
            time_val_next = '0;
        end else begin
            time_val_next = time_val + 1;
        end
    end

    initial begin
        rst_l = 0;
        repeat (1) @(posedge clk);
        rst_l = 1;
        training = 1;
        training_spikes_fd = $fopen("training_spikes.csv", "r");
        //read in data from the training set every 8 clocks
        while(! $feof(training_spikes_fd))begin
            // fill spikes into spike_times
            for(i=0; i < `num_spikes; i++)begin
                $fscanf(training_spikes_fd, "%d\n", spike_times[i]);            
                //$display("value of spikes[%1d]: %b", i, spike_times[i]);
            end
            repeat (8) @(posedge clk);
        end
        $fclose(training_spikes_fd);

        training = 0;
        testing_spikes_fd = $fopen("testing_spikes.csv", "r");
        testing_results_fd = $fopen("testing_results.csv", "w");
        while(! $feof(training_spikes_fd))begin
            // fill spikes into spike_times
            for(i=0; i < `num_spikes; i++)begin
                $fscanf(testing_spikes_fd, "%d\n", spike_times[i]);            
            //    $display("value of spikes[%1d]: %b", i, spike_times[i]);
            end
            repeat (7) @(posedge clk);
            $fdisplay(testing_results_fd, "%d", winning_neuron);
            repeat (1) @(posedge clk);
        end
        $fclose(testing_spikes_fd);
        $fclose(testing_results_fd);


        $finish;
    end
endmodule
