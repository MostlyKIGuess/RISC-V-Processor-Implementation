module hazard_unit(
    
    input [4:0] rs1E,
    input [4:0] rs2E,
    input [4:0] write_regM,
    input [4:0] write_regW,
    input reg_writeM,
    input reg_writeW,
    output reg [1:0] forwardAE,
    output reg [1:0] forwardBE,

    input [4:0] rs1D,
    input [4:0] rs2D,
    input [4:0] rdE,
    input mem_to_regE,
    output reg stallF,
    output reg stallD,
    output reg flushE,

    input branchD,
    input reg_writeE,
    input mem_to_regM,
    output reg forwardAD,
    output reg forwardBD

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

    always @(*) begin
        forwardAD = (rs1D!=0) & (rs1D==write_regM) & reg_writeM;
        forwardBD = (rs2D!=0) & (rs2D==write_regM) & reg_writeM;
    end

    wire lwstall;
    assign lwstall = ((rs1D==rdE) | (rs2D==rdE)) & mem_to_regE;

    wire branchstall;
    assign branchstall = (branchD & reg_writeE & (rdE==rs1D | rdE==rs2D)) | (branchD & mem_to_regM & (write_regM==rs1D | write_regM==rs2D));

    always @(*) begin
        stallF = lwstall | branchstall;
        stallD = lwstall | branchstall;
        flushE = lwstall | branchstall;
    end

endmodule