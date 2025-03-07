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
    output reg flushE

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

    wire lwstall;
    assign lwstall = ((rs1D==rdE) | (rs2D==rdE)) & mem_to_regE;
    always @(*) begin
        stallF = lwstall;
        stallD = lwstall;
        flushE = lwstall;
    end

endmodule