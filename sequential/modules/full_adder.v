`timescale 1ns/1ps

module full_adder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    wire xor1_out, and1_out, and2_out;
    xor u1 (xor1_out, a, b);
    xor u2 (sum, xor1_out, cin);
    and u3 (and1_out, a, b);
    and u4 (and2_out, cin, xor1_out);
    or u5 (cout, and1_out, and2_out);
endmodule