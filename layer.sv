`timescale 1ns/1ps

`include "define.vh"

module layer(
    input logic clk, rst_l,
    input logic [$clog2(`time_period):0] time_val,
    input logic [$clog2(`num_spikes)-1:0][$clog2(`time_period):0] spike_times,
    output logic [$clog2(`time_period):0] output_spike_time


);
    genvar i;

    logic [$clog2(`neurons_per_layer)-1:0] li_winning_neuron, winning_neuron_next, winning_neuron;

    logic [$clog2(`neurons_per_layer)-1:0][`num_spikes-1:0][`WBITS-1:0] weights_next, weights_ff;

    logic [$clog2(`time_period):0] li_output_spike_time, output_spike_time_next, output_spike_time_ff, output_spike_time_ff_next;

   

    always_ff @(posedge clk or negedge rst_l)begin
        if(rst_l == 1'b0)begin
            output_spike_time <= '0;
            output_spike_time_ff <= '0;
            winning_neuron <= '0;
            weights_ff <= 0;
        end else begin
            output_spike_time_ff <= output_spike_time_ff_next;
            output_spike_time <= output_spike_time_next;
            winning_neuron <= winning_neuron_next;
            weights_ff <= weights_next;
        end
    end


    logic [$clog2(`num_spikes)-1:0] generated_spikes, spike_enable_l, spike_enable_inhibited;
    logic [$clog2(`neurons_per_layer)-1:0] neuron_spikes;



    ffi ffi1(.should_spike_in_l(spike_enable_l), .should_spike_out(spike_enable_inhibited));



    generate
        //spike generation
        for(i = 0; i < `num_spikes; i++)begin
            assign spike_enable_l[i] = spike_times[i][$clog2(`time_period)];
            spike_generation sg(.time_val(time_val),
                             .should_spike(spike_enable_inhibited[i]),
                             .spike_time(spike_times[i][$clog2(`time_period)-1:0]),
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
                          .last_output_spike(output_spike_time_ff[$clog2(`time_period)]),
                          .last_output_spike_time(output_spike_time_ff[$clog2(`time_period)-1:0]),
                          .last_winning_neuron(winning_neuron),
                          .output_spike(li_output_spike_time[$clog2(`time_period)]),
                          .output_spike_time(li_output_spike_time[$clog2(`time_period)-1:0]),
                          .winning_neuron(li_winning_neuron)
                           );
    
    generate
        //stdp
        for(i = 0; i < `neurons_per_layer; i++)begin
            if(time_val == `time_period - 1)begin
                if(winning_neuron == i)begin
                    if(neuron_spikes[i] == 1'b1)begin
                        assign weights_next[i] = `wmax;        
                    end else begin
                        assign weights_next[i] = '0;        
                    end
                end else if(neuron_spikes[i] == 1'b1)begin
                    if(neuron_spikes[i] == 1'b1)begin
                        assign weights_next[i] = '0;
                    end else begin
                        assign weights_next[i] = weights_ff[i];
                    end
                end else begin
                    if(spike_times[i][$clog2(`time_period)] == 1'b0 && weights_ff[i] < `wmax )begin
                        assign weights_next[i] = weights_ff[i] + '1;
                    end else begin
                        assign weights_next[i] = weights_ff[i];
                    end
                end
            end else begin
                assign weights_next[i] = weights_ff[i];
            end
        end

    endgenerate


    always_comb begin
        if(time_val == `time_period - 1)begin
            output_spike_time_next = li_output_spike_time;
            output_spike_time_ff_next = `time_period - 1;
            winning_neuron_next = '0;
        end else begin
            output_spike_time_next = output_spike_time;
            output_spike_time_ff_next = li_output_spike_time;
            winning_neuron_next = li_winning_neuron;;

        end
    end

endmodule
