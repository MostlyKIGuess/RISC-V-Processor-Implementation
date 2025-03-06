`timescale 1ns/1ps

module ex_mem_register (
    input wire clk,
    input wire reset,
    input wire en,
    input wire [294:0] d,
    output reg [294:0] q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= {295{1'b0}};
        else if (en)
            q <= d;
    end
    
endmodule
