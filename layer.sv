`timescale 1ns/1ps
//`default_nettype none
`include "internal_defines.vh"

module layer(
    input logic clk, rst_l, training,
    input logic [`log_time_period:0] time_val,
    input logic [`num_spikes-1:0][`log_time_period:0] spike_times,
    output logic [`log_time_period:0] output_spike_time,
    output logic [`log_neurons_per_layer:0]  winning_neuron

);
    genvar i;

    logic [`log_neurons_per_layer:0] li_winning_neuron, winning_neuron_next;

    logic [`neurons_per_layer-1:0][`num_spikes-1:0][`WBITS-1:0] weights_next, weights_ff;

    logic [`log_time_period:0] li_output_spike_time, output_spike_time_next, output_spike_time_ff, output_spike_time_ff_next;

   

    always_ff @(posedge clk or negedge rst_l)begin
        if(rst_l == 1'b0)begin
            output_spike_time <= '0;
            output_spike_time_ff <= '0;
            winning_neuron <= -1;
            weights_ff <= 0;
        end else begin
            output_spike_time_ff <= output_spike_time_ff_next;
            output_spike_time <= output_spike_time_next;
            winning_neuron <= winning_neuron_next;
            weights_ff <= weights_next;
        end
    end


    logic [`num_spikes-1:0] generated_spikes, spike_enable_l, spike_enable_inhibited;
    logic [`neurons_per_layer-1:0] neuron_spikes;

 

    ffi ffi1(.should_spike_in_l(spike_enable_l), .should_spike_out(spike_enable_inhibited));



    generate
        //spike generation
        for(i = 0; i < `num_spikes; i++)begin
            assign spike_enable_l[i] = spike_times[i][`log_time_period];
            spike_generation sg(.time_val(time_val),
                             .should_spike(spike_enable_inhibited[i]),
                             .spike_time(spike_times[i][`log_time_period-1:0]),
                             .spike_val(generated_spikes[i])
                            );
        end
    endgenerate

    generate
        //accumulator
        for(i = 0; i < `neurons_per_layer; i++)begin
            neuron n(.spikes_in(generated_spikes),
                     .weights(weights_ff[i]),
                     .spikes_out(neuron_spikes[i]));
                     

        end

    endgenerate

    lateral_inhibition li(.time_val(time_val),
                          .spike_volley(neuron_spikes),
                          .last_output_spike(output_spike_time_ff[`log_time_period]),
                          .last_output_spike_time(output_spike_time_ff[`log_time_period-1:0]),
                          .last_winning_neuron(winning_neuron),
                          .output_spike(li_output_spike_time[`log_time_period]),
                          .output_spike_time(li_output_spike_time[`log_time_period-1:0]),
                          .winning_neuron(li_winning_neuron)
                           );
    logic debugging;
    always_comb begin
         debugging = 0;
        //stdp
        if(training == 1'b1 && time_val == `time_period - 1)begin
            for(int stdp_neuron = 0; stdp_neuron < `neurons_per_layer; stdp_neuron++)begin
                for(int spike = 0; spike < `num_spikes; spike++)begin
                    if($unsigned(winning_neuron[4:0]) == $unsigned(stdp_neuron[4:0]))begin
                        if(generated_spikes[spike] == 1'b1)begin
                            debugging = 1;
			    weights_next[stdp_neuron][spike] = `wmax;
                        end else begin
                            weights_next[stdp_neuron][spike] = '0;     
                        end
                    end else if(neuron_spikes[stdp_neuron] == 1'b1)begin
                        if(generated_spikes[spike] == 1'b1)begin
                            weights_next[stdp_neuron][spike] = '0;
                        end else begin
                            weights_next[stdp_neuron][spike] = weights_ff[stdp_neuron][spike];
                        end
                    end else begin
                        if(generated_spikes[spike] == 1'b1 && weights_ff[stdp_neuron][spike] < `wmax )begin
                            weights_next[stdp_neuron][spike] = weights_ff[stdp_neuron][spike] + 3'd1;
                        end else begin
                            weights_next[stdp_neuron][spike] = weights_ff[stdp_neuron][spike];
                        end
                    end
                end
            end
		end else begin
            weights_next = weights_ff;
        end

        if(time_val == `time_period - 1)begin
            output_spike_time_next = -1;
            output_spike_time_ff_next = `time_period - 1;
            winning_neuron_next = -1;
        end else begin
            output_spike_time_next = li_output_spike_time;
            output_spike_time_ff_next = li_output_spike_time;
            winning_neuron_next = li_winning_neuron;

        end
    end

endmodule
