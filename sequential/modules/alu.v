`timescale 1ns/1ps

`include "full_adder.v"
`include "mux2to1.v"
`include "add_sub.v"
`include "xor_.v"
`include "or_.v"
`include "and_.v"
`include "sll.v"
`include "sr.v"
`include "slt_sltu.v"

module alu(
    input [31:0] instruction,
    input [63:0] in1,
    input [63:0] in2,
    output reg [63:0] out 
);

    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    // ----------------ADD/SUB----------------

    wire [63:0] sum_out;
    wire [64:0] carry;

    add_sub add_sub_unit(
        .in1(in1),
        .in2(in2),
        .funct7(funct7),
        .funct3(funct3),
        .sum_out(sum_out),
        .carry(carry)
    );

    // ----------------XOR/OR/AND----------------

    wire [63:0] xor_out;
    wire [63:0] or_out;
    wire [63:0] and_out;

    // literally just chained gates
    xor_ xor_unit(
        .in1(in1),
        .in2(in2),
        .out(xor_out)
    );
    or_ or_unit(
        .in1(in1),
        .in2(in2),
        .out(or_out)
    );
    and_ and_unit(
        .in1(in1),
        .in2(in2),
        .out(and_out)
    );

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

    slt_sltu slt_sltu_unit(
        .sum_out(sum_out),
        .carry(carry),
        .slt_out(slt_out),
        .sltu_out(sltu_out)
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