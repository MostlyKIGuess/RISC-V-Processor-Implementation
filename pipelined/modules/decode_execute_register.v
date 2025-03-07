`timescale 1ns/1ps

module decode_execute_register (
    input wire clk,
    input wire reset,
    input wire flush,
    input wire [293:0] d,
    output reg [293:0] q
);
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 294'b0;  // Synchronous reset (on reset)
        else if (flush)
            q[293:1] <= 293'b0;  // Asynchronous flush (only clears bits 293:1)
        else
            q <= d;  // Normal update
    end
    
endmodule
