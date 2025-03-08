`timescale 1ns/1ps

module memory_writeback_register (
    input wire clk,
    input wire reset,
    input wire [162:0] d,
    output reg [162:0] q
);

    initial begin
        q = 163'b0;
    end

    always @(posedge clk) begin
        q <= d;
    end
    
endmodule
