`timescale 1ns/1ps

module execute_memory_register (
    input wire clk,
    input wire reset,
    input wire [164:0] d,
    output reg [164:0] q
);

    initial begin
        q = 165'b0;
    end

    always @(posedge clk) begin
        q <= d;
    end
    
endmodule
