module add_sub(
    input [63:0] in1,
    input [63:0] in2,
    input [6:0] funct7,
    input [2:0] funct3,
    output [63:0] sum_out,
    output [64:0] carry
);
    genvar i;

    // set to sub if instruction sub, or slt/sltu
    // this couldve been one line with operators :(
    wire temp1a;
    wire temp1b;
    wire temp2a;
    wire temp2b;
    wire temp3a;
    wire temp3b;
    wire temp3c;
    wire temp4;
    wire sub;
    and (temp1a, funct3[0], funct3[1]);
    and (temp1b, temp1a, ~funct3[2]);
    and (temp2a, ~funct3[0], funct3[1]);
    and (temp2b, temp2a, ~funct3[2]);
    and (temp3a, ~funct3[0], ~funct3[1]);
    and (temp3b, temp3a, ~funct3[2]);
    and (temp3c, temp3b, funct7[5]);
    or (temp4, temp1b, temp2b);
    or (sub, temp4, temp3c);

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