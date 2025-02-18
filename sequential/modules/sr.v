module sr(
    input [63:0] in,
    input [63:0] shift_amt,
    input [6:0] funct7,
    output [63:0] sr_out
);

    // https://vlsigyan.com/wp-content/uploads/2018/04/001_18_04_2018.jpg

    wire [63:0] sr_shift0, sr_shift1, sr_shift2, sr_shift3, sr_shift4;

    wire [63:0] sr_inputs0a, sr_inputs0b;
    wire [63:0] sr_inputs1a, sr_inputs1b;
    wire [63:0] sr_inputs2a, sr_inputs2b;
    wire [63:0] sr_inputs3a, sr_inputs3b;
    wire [63:0] sr_inputs4a, sr_inputs4b;
    wire [63:0] sr_inputs5a, sr_inputs5b;

    wire sr_bit;
    mux2to1 mux_sr(
        .sel(funct7[5]),
        .in0(1'b0),
        .in1(in[63]),
        .out(sr_bit)
    );

    genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_inputs_sr
            assign sr_inputs0a[i] = in[i];
            assign sr_inputs1a[i] = sr_shift0[i];
            assign sr_inputs2a[i] = sr_shift1[i];
            assign sr_inputs3a[i] = sr_shift2[i];
            assign sr_inputs4a[i] = sr_shift3[i];
            assign sr_inputs5a[i] = sr_shift4[i];
            assign sr_inputs0b[i] = (i < 32) ? in[i+32]        : sr_bit;
            assign sr_inputs1b[i] = (i < 48) ? sr_shift0[i+16] : sr_bit;
            assign sr_inputs2b[i] = (i < 56) ? sr_shift1[i+8]  : sr_bit;
            assign sr_inputs3b[i] = (i < 60) ? sr_shift2[i+4]  : sr_bit;
            assign sr_inputs4b[i] = (i < 62) ? sr_shift3[i+2]  : sr_bit;
            assign sr_inputs5b[i] = (i < 63) ? sr_shift4[i+1]  : sr_bit;
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : sr_chain
            mux2to1 mux0(
                .sel(shift_amt[5]),
                .in0(sr_inputs0a[i]),
                .in1(sr_inputs0b[i]),
                .out(sr_shift0[i])
            );
            mux2to1 mux1(
                .sel(shift_amt[4]),
                .in0(sr_inputs1a[i]),
                .in1(sr_inputs1b[i]),
                .out(sr_shift1[i])
            );
            mux2to1 mux2(
                .sel(shift_amt[3]),
                .in0(sr_inputs2a[i]),
                .in1(sr_inputs2b[i]),
                .out(sr_shift2[i])
            );
            mux2to1 mux3(
                .sel(shift_amt[2]),
                .in0(sr_inputs3a[i]),
                .in1(sr_inputs3b[i]),
                .out(sr_shift3[i])
            );
            mux2to1 mux4(
                .sel(shift_amt[1]),
                .in0(sr_inputs4a[i]),
                .in1(sr_inputs4b[i]),
                .out(sr_shift4[i])
            );
            mux2to1 mux5(
                .sel(shift_amt[0]),
                .in0(sr_inputs5a[i]),
                .in1(sr_inputs5b[i]),
                .out(sr_out[i])
            );
        end
    endgenerate

endmodule
