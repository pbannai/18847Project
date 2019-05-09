`timescale 1ns/1ps
 `default_nettype none
`include "internal_defines.vh"

module lateral_inhibition(
    input logic [`log_time_period:0] time_val,
    input logic [`neurons_per_layer-1:0] spike_volley,
    input logic last_output_spike,
    input logic [`log_testing_period-1:0]  last_output_spike_time,
    input logic [`log_neurons_per_layer:0] last_winning_neuron,
    output logic output_spike,
    output logic [`log_testing_period-1:0] output_spike_time,
    output logic [`log_neurons_per_layer:0] winning_neuron

);



    always_comb begin
        output_spike_time = '0;
        output_spike = 1'b0;
        if(last_winning_neuron == 5'b11111 && $unsigned(time_val) < `testing_period)begin
            winning_neuron = -1;
            for(int i = 0; i < `neurons_per_layer; i++) begin
                if(spike_volley[i] == 1'b1)begin
                    output_spike_time = time_val;
                    output_spike = 1'b0;
                    winning_neuron = i;                   
                end 
            end
        end else begin
            output_spike_time = last_output_spike_time;
            output_spike = last_output_spike;
            winning_neuron = last_winning_neuron;
        end
    end




endmodule
