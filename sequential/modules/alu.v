`timescale 1ns/1ps

`include "full_adder.v"
`include "mux2to1.v"
`include "sll.v"
`include "sr.v"

module alu(
    input [31:0] instruction,
    input [63:0] in1,
    input [63:0] in2,
    output reg [63:0] out 
);

    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    genvar i;

    // ----------------ADD/SUB----------------

    wire [63:0] sum_out;
    wire [64:0] carry;

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

    // ----------------XOR/OR/AND----------------

    wire [63:0] xor_out;
    wire [63:0] or_out;
    wire [63:0] and_out;

    // literally just chained gates
    generate
        for (i = 0; i < 64; i = i + 1) begin : xor_or_and
            xor(
                xor_out[i],
                in1[i],
                in2[i]
            );
            or(
                or_out[i],
                in1[i],
                in2[i]
            );
            and(
                and_out[i],
                in1[i],
                in2[i]
            );
        end
    endgenerate

    // ----------------SLL----------------

    wire [63:0] sll_out;

    // implemented using a barrel shifter
    sll sll_unit(
        .in(in1),
        .shift_amt(in2),
        .sll_out(sll_out)
    );

    // ----------------SRL/A----------------

    wire [63:0] sr_out;

    // barrel shifter + mux to select bw srl/a
    sr sr_unit(
        .in(in1),
        .shift_amt(in2),
        .funct7(funct7),
        .sr_out(sr_out)
    );

    // ----------------SLT/SLTU----------------

    wire slt_out;
    wire sltu_out;

    assign slt_out = sum_out[63];
    not(
        sltu_out,
        carry[64]
    );

    always @(*) begin
        case (funct3)
            3'h0: out = sum_out;
            3'h4: out = xor_out;
            3'h6: out = or_out;
            3'h7: out = and_out;
            3'h1: out = sll_out;
            3'h5: out = sr_out;
            3'h2: out = {63'b0, slt_out};
            3'h3: out = {63'b0, sltu_out};
        endcase
    end

endmodule