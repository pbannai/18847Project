`include "internal_defines.vh"

module rom(
    input clk,
    input [15:0] addr,
    output reg [31:0] read_data);

    reg [31:0] memory [2**16-1:0];

    initial begin
        $readmemb("training_spikes.mem", memory);
    end

    always @(posedge clk) begin
        read_data <= memory[addr];
    end
endmodule

module mem_controller(
    input clk, rst_l,
    output reg [15:0] addr);

    reg [`log_time_period-1:0] timer;
    
    always @(posedge clk or negedge rst_l) begin
        if (~rst_l) begin
            timer <= 0;
        end
        else begin
            timer <= timer + 1;
        end
    end

    always @(posedge clk or negedge rst_l) begin
        if(~rst_l) begin
            addr <= 0;
        end
        else if (timer == 3'b111) begin
            addr <= addr + 1'b1;
        end
        else begin
            addr <= addr;
        end
    end

endmodule
