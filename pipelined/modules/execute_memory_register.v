`timescale 1ns/1ps

module execute_memory_register (
    input wire clk,
    input wire reset,
    input wire [164:0] d,
    output reg [164:0] q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= {165{1'b0}};
        else
            q <= d;
    end
    
endmodule
