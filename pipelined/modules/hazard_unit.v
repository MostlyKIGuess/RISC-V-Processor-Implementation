module hazard_unit(
    input [4:0] rs1E,
    input [4:0] rs2E,
    input [4:0] write_regM,
    input [4:0] write_regW,
    input reg_writeM,
    input reg_writeW,
    output reg [1:0] forwardAE,
    output reg [1:0] forwardBE
);

    always @(*) begin
        if ((rs1E!=0) & (rs1E==write_regM) & reg_writeM) 
            forwardAE = 2'b10;
        else if ((rs1E!=0) & (rs1E==write_regW) & reg_writeW) 
            forwardAE = 2'b01;
        else 
            forwardAE = 2'b00;
    end

    always @(*) begin
        if ((rs2E!=0) & (rs2E==write_regM) & reg_writeM) 
            forwardBE = 2'b10;
        else if ((rs2E!=0) & (rs2E==write_regW) & reg_writeW) 
            forwardBE = 2'b01;
        else 
            forwardBE = 2'b00;
    end

endmodule