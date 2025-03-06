`timescale 1ns/1ps

module mem_wb_register (
    input wire clk,
    input wire reset,
    input wire en,
    input wire [162:0] d,
    output reg [162:0] q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= {163{1'b0}};
        else if (en)
            q <= d;
    end
    
endmodule
