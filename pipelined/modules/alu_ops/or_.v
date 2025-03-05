module or_(
    input [63:0] in1,
    input [63:0] in2,
    output [63:0] out
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : or_chain
            or or_inst(
                out[i],
                in1[i],
                in2[i]
            );
        end
    endgenerate
endmodule