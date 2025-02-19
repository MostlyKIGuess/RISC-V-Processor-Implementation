module control_unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg mem_read,
    output reg mem_write,
    output reg reg_write,
    output reg branch
);
    always @(*) begin
        case(opcode)
            7'b0110011: begin 
                mem_read = 0;
                mem_write = 0;
                reg_write = 1;
                branch = 0;
            end
            // more cases left yet

        endcase
    end
endmodule
