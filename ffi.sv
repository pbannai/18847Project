`timescale 1ns/1ps
 `default_nettype none
`include "internal_defines.vh"

module ffi(

    input logic [`num_spikes-1:0] should_spike_in_l,
    output logic [`num_spikes-1:0] should_spike_out

);

    logic [$clog2(`num_spikes)-1:0] num_spikes;

    always_comb begin
        num_spikes = '0;  
        foreach(should_spike_in_l[i]) begin
            num_spikes += !should_spike_in_l[i];
        end
        if($unsigned(num_spikes) > `ffi_max)begin
            should_spike_out = ~should_spike_in_l;
        end else begin
            should_spike_out = '0;
        end
    end

endmodule
