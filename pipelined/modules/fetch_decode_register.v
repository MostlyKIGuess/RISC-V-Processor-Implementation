`timescale 1ns/1ps

module fetch_decode_register (
    input wire clk,
    input wire reset,
    input wire flush,
    input wire enable,
    input wire [96:0] d,
    output reg [96:0] q
);
    
    initial begin
        q = 97'b0;
    end

    always @(posedge clk) begin
    if (flush)
            q[96:1] <= 96'b0;
    else if (enable)
        q <= d;
    end
    
endmodule
