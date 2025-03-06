`timescale 1ns/1ps

module if_id_register (
    input wire clk,
    input wire reset,
    input wire en,
    input wire [96:0] d,
    output reg [96:0] q
);
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= {97{1'b0}};
        else if (en)
            q <= d;
    end
    
endmodule
