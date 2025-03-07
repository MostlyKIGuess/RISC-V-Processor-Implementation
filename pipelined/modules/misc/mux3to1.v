module mux3to1 (
    input wire [63:0] in0, in1, in2,  // Three 64-bit input signals
    input wire [1:0] sel,             // 2-bit selector
    output reg [63:0] out             // 64-bit output
);

always @(*) begin
    case (sel)
        2'b00: out = in0; // Select in0
        2'b01: out = in1; // Select in1
        2'b10: out = in2; // Select in2
        default: out = 64'b0; // Default case (zero output)
    endcase
end

endmodule
