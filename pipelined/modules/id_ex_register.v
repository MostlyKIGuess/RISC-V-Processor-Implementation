`timescale 1ns/1ps

module id_ex_register (
    input wire clk,
    input wire reset,
    input wire en,
    input wire [229:0] d,
    output reg [229:0] q
);
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= {230{1'b0}};
        else if (en)
            q <= d;
    end
    
endmodule
