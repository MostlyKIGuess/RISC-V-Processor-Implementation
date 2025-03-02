module control_unit(
    input [31:0] instruction,
    output reg branch,
    output reg mem_read,
    output reg mem_to_reg,
    output reg mem_write,
    output reg alu_src,
    output reg reg_write
);
    // Instruction fields
    wire [6:0] opcode = instruction[6:0];
    
    always @(*) begin
        case(opcode)
            7'b0110011: begin    // R-type 
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;     // Use register for operand B
                reg_write = 1;
            end
            
            7'b0000011: begin    // Load instructions (ld)
                branch = 0;
                mem_read = 1;
                mem_to_reg = 1;
                mem_write = 0;
                alu_src = 1;     // Use immediate for address
                reg_write = 1;
            end
            
            7'b0100011: begin    // Store instructions (sd)
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 1;
                alu_src = 1;     // Use immediate for address
                reg_write = 0;
            end
            
            7'b1100011: begin    // Branch instructions (beq)
                branch = 1;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;     // Use register for comparison
                reg_write = 0;
            end

            7'b0010011: begin    // I-type instructions (addi)
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 1;     // Use immediate
                reg_write = 1;
            end
            
            default: begin       // Invalid instruction
                branch = 0;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                reg_write = 0;
            end
        endcase
    end

endmodule
