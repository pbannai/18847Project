`timescale 1ns/1ps

`include "define.vh"

module ffi(

    input logic [`receptive_field-1:0] spikes_in,
    output logic [`receptive_field-1:0] spikes_out

);

    logic [$clog2(`receptive_field)-1:0] num_spikes;

    always_comb begin
        num_spikes = '0;  
        foreach(spikes_in[i]) begin
            num_spikes += spikes_in[i];
        end
        if($unsigned(num_spikes) > `ffi_max)begin
            spikes_out = spikes_in;
        end else begin
            spikes_out = '0;
        end
    end

endmodule
