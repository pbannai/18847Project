`timescale 1ns/1ps

`include "define.vh"

module lateral_inhibition(
    input logic clk, rst_l,
    input logic [$clog2(`time_period)-1:0] time_val,
    input logic [`neurons_per_layer-1:0] spike_volley,
    output logic output_spike,
    output logic [$clog2(`time_period)-1:0] output_spike_time,
    output logic [$clog2(`neurons_per_layer)-1:0] winning_neuron

);

    logic [$clog2(`neurons_per_layer)-1:0] winning_neuron_next;
    logic [$clog2(`time_period)-1:0] output_spike_time_next,
    logic output_spike_next;


    always_ff @(posedge clk or negedge rst_l)begin
        if(rst_l == 1'b0)begin
            output_spike_time <= '0;
            output_spike <= 1'b0;
            winning_neuron <= '0;
        end else begin
            output_spike_time <= output_spike_time_next;
            output_spike <= output_spike_next;
            winning_neuron <= winning_neuron_next;
        end
    end

    always_comb begin
           
        if(output_spike == 1'b0)begin
            foreach(spike_volley[i]) begin
                if(spike_volley[i] == 1'b1 && output_spike == 1'b0)begin
                    output_spike_time_next = time_val;
                    output_spike_next = 1'b1;
                    winning_neuron_next = i;                   
                end 
            end
        end else begin
            output_spike_time_next = output_spike_time;
            output_spike_next = output_spike;
            winning_neuron_next = winning_neuron;

        end


    end




endmodule
