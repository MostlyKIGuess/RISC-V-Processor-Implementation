`timescale 1ns/1ps

module memory_writeback_register (
    input wire clk,
    input wire reset,
    input wire [162:0] d,
    output reg [162:0] q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= {163{1'b0}};
        else
            q <= d;
    end
    
endmodule
