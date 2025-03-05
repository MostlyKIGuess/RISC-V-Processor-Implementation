module slt_sltu(
    input [63:0] sum_out,
    input [64:0] carry,
    output slt_out,
    output sltu_out
);
    assign slt_out = sum_out[63];
    not(
        sltu_out,
        carry[64]
    );
endmodule