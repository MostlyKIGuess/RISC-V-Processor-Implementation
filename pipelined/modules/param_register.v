`timescale 1ns/1ps

module param_register #(parameter WIDTH = 1) (
    input wire clk,
    input wire reset,
    input wire en,
    input wire [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else if (en)
            q <= d;
    end
    
endmodule
