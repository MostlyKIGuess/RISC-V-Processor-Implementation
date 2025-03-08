`timescale 1ns/1ps

module decode_execute_register (
    input wire clk,
    input wire reset,
    input wire flush,
    input wire [293:0] d,
    output reg [293:0] q
);
    
    initial begin
        q = 294'b0;
    end

    always @(posedge clk or posedge flush) begin
        if (flush)
            q[293:1] <= 293'b0;  // Asynchronous flush (only clears bits 293:1)
        else
            q <= d;  // Normal update
    end
    
endmodule
