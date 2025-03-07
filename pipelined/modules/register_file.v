module register_file(
    input clk,
    input reg_write,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    output reg signed [63:0] read_data1,
    output reg signed [63:0] read_data2,
    input signed [63:0] write_data
);
    reg signed [63:0] registers [0:31];
    
    always @(negedge clk) begin
        read_data1 = (rs1 == 0) ? 64'b0 : registers[rs1];
        read_data2 = (rs2 == 0) ? 64'b0 : registers[rs2];
    end

    always @(posedge clk) begin
        if (reg_write && rd != 0)
            registers[rd] <= write_data;
    end

    // yeh karna padega warna starting mein kya hoga bhai?
    initial begin
        for(integer i = 0; i < 32; i = i + 1) begin
            registers[i] = 64'b0;
        end
    end
endmodule
    
