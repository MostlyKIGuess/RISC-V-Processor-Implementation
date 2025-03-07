`timescale 1ns/1ps

module decode_execute_register (
    input wire clk,
    input wire reset,
    input wire [293:0] d,
    output reg [293:0] q
);
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= {294{1'b0}};
        else
            q <= d;
    end
    
endmodule
