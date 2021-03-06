`timescale 1ns/1ps
`include "internal_defines.vh"

module layer_top(
    input wire clk, rst, 
    output wire [`log_neurons_per_layer:0] winning_neuron,
    output wire [`log_time_period:0] output_spike_time
);

    wire  [`num_spikes*`log_time_period-1:0] spike_times;
    reg [`log_time_period:0] time_val;
    wire rst_l;

    assign rst_l = ~rst;
    
    always @(posedge clk or negedge rst_l) begin
        if(rst_l == 1'b0) begin
            time_val <= 0;
        end
        else if(time_val == `time_period-1) begin
            time_val <= 0;
        end
        else begin
            time_val <= time_val + 1'b1;
        end
    end
    
    mem_controller Mem_Ctrl(.clk(clk), .rst_l(rst_l), .read_data(spike_times));
    
    layer L0 (.clk(clk),
              .training(1'b1),
              .rst_l(rst_l),
              .time_val(time_val),
              .spike_times(spike_times),
              .output_spike_time(output_spike_time),
              .winning_neuron(winning_neuron)
             );
endmodule
