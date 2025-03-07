`timescale 1ns/1ps

module execute_memory_register (
    input wire clk,
    input wire reset,
    input wire [229:0] d,
    output reg [229:0] q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= {230{1'b0}};
        else
            q <= d;
    end
    
endmodule
