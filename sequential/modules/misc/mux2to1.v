`timescale 1ns/1ps

module mux2to1(
    input sel,
    input in0,
    input in1,
    output out
);
    wire not_sel, and0_out, and1_out;
    not u1 (not_sel, sel);
    and u2 (and0_out, in0, not_sel);
    and u3 (and1_out, in1, sel);
    or u4 (out, and0_out, and1_out);
endmodule