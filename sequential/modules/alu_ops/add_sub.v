module add_sub(
    input signed [63:0] in1,
    input signed [63:0] in2,
    input sub,
    output signed [63:0] sum_out,
    output signed [64:0] carry
);
    genvar i;

    // xor in2 with 0xFFFFFFFF if sub to invert
    wire [63:0] in2_mod;
    generate
        for (i = 0; i < 64; i = i + 1) begin : xor_sub
            xor(
                in2_mod[i],
                in2[i],
                sub
            );
        end
    endgenerate

    assign carry[0] = sub; // add 1 for subtraction

    generate
        for (i = 0; i < 64; i = i + 1) begin : adder_chain
            full_adder fa(
                .a(in1[i]),
                .b(in2_mod[i]),
                .cin(carry[i]),
                .sum(sum_out[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

endmodule