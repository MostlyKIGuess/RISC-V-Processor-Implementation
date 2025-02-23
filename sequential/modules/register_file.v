module register_file(
    input clk,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input signed  [63:0] write_data,
    input reg_write,
    output signed  [63:0] read_data1,
    output signed  [63:0] read_data2
);
    reg signed [63:0] registers [0:31];
    
    assign read_data1 = (rs1 == 0) ? 64'b0 : registers[rs1];
    assign read_data2 = (rs2 == 0) ? 64'b0 : registers[rs2];
    
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
    
