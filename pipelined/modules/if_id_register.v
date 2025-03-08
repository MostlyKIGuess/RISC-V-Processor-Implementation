`timescale 1ns/1ps

module if_id_register (
    input wire clk,
    input wire reset,
    input wire en,
    input wire [161:0] d,
    output reg [161:0] q
);
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= {162{1'b0}};
        else if (en)
            q <= d;
    end
    
endmodule
