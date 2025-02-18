module sll(
    input [63:0] in,
    input [63:0] shift_amt,
    output [63:0] sll_out
);
    // this code doesnt make much sense to me anymore but it replicates this circuit for 64 bits
    // https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.researchgate.net%2Ffigure%2FBarrel-Shifter-design-1_fig1_281666651&psig=AOvVaw1qxWsBfqVG4zNtLqSa6rsc&ust=1739127352475000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCOjg47LgtIsDFQAAAAAdAAAAABAE

    wire [63:0] sll_shift0, sll_shift1, sll_shift2, sll_shift3, sll_shift4;
    wire [63:0] sll_inputs0a, sll_inputs0b;
    wire [63:0] sll_inputs1a, sll_inputs1b;
    wire [63:0] sll_inputs2a, sll_inputs2b;
    wire [63:0] sll_inputs3a, sll_inputs3b;
    wire [63:0] sll_inputs4a, sll_inputs4b;
    wire [63:0] sll_inputs5a, sll_inputs5b;
    
    genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_inputs_sll
            assign sll_inputs0a[i] = in[i];
            assign sll_inputs1a[i] = sll_shift0[i];
            assign sll_inputs2a[i] = sll_shift1[i];
            assign sll_inputs3a[i] = sll_shift2[i];
            assign sll_inputs4a[i] = sll_shift3[i];
            assign sll_inputs5a[i] = sll_shift4[i];
            assign sll_inputs0b[i] = (i > 0)  ? in[i-1]          : 1'b0;
            assign sll_inputs1b[i] = (i > 1)  ? sll_shift0[i-2]  : 1'b0;
            assign sll_inputs2b[i] = (i > 3)  ? sll_shift1[i-4]  : 1'b0;
            assign sll_inputs3b[i] = (i > 7)  ? sll_shift2[i-8]  : 1'b0;
            assign sll_inputs4b[i] = (i > 15) ? sll_shift3[i-16] : 1'b0;
            assign sll_inputs5b[i] = (i > 31) ? sll_shift4[i-32] : 1'b0;
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : sll_chain
            mux2to1 mux0(
                .sel(shift_amt[0]),
                .in0(sll_inputs0a[i]),
                .in1(sll_inputs0b[i]),
                .out(sll_shift0[i])
            );
            mux2to1 mux1(
                .sel(shift_amt[1]),
                .in0(sll_inputs1a[i]),
                .in1(sll_inputs1b[i]),
                .out(sll_shift1[i])
            );
            mux2to1 mux2(
                .sel(shift_amt[2]),
                .in0(sll_inputs2a[i]),
                .in1(sll_inputs2b[i]),
                .out(sll_shift2[i])
            );
            mux2to1 mux3(
                .sel(shift_amt[3]),
                .in0(sll_inputs3a[i]),
                .in1(sll_inputs3b[i]),
                .out(sll_shift3[i])
            );
            mux2to1 mux4(
                .sel(shift_amt[4]),
                .in0(sll_inputs4a[i]),
                .in1(sll_inputs4b[i]),
                .out(sll_shift4[i])
            );
            mux2to1 mux5(
                .sel(shift_amt[5]),
                .in0(sll_inputs5a[i]),
                .in1(sll_inputs5b[i]),
                .out(sll_out[i])
            );
        end
    endgenerate

endmodule
