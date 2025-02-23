module control_unit(
    input [31:0] instruction,
    input signed [63:0] in1,           // ALU operand 1
    input signed [63:0] in2,           // ALU operand 2
    output reg mem_read,
    output reg mem_write,
    output reg reg_write,
    output reg branch,
    output reg alu_src,
    output signed [63:0] alu_result
);
    // Instruction fields
    wire [6:0] opcode = instruction[6:0];

    alu alu_inst(
        .instruction(instruction),
        .in1(in1),
        .in2(in2),
        .out(alu_result)
    );

    
    always @(*) begin
        case(opcode)
            7'b0110011: begin    // R-type 
                mem_read = 0;
                mem_write = 0;
                reg_write = 1;
                branch = 0;
                alu_src = 0;     // Use register for operand B
            end
            
            7'b0000011: begin    // Load instructions (ld)
                mem_read = 1;
                mem_write = 0;
                reg_write = 1;
                branch = 0;
                alu_src = 1;     // Use immediate for address
            end
            
            7'b0100011: begin    // Store instructions (sd)
                mem_read = 0;
                mem_write = 1;
                reg_write = 0;
                branch = 0;
                alu_src = 1;     // Use immediate for address
            end
            
            7'b1100011: begin    // Branch instructions (beq)
                mem_read = 0;
                mem_write = 0;
                reg_write = 0;
                branch = 1;
                alu_src = 0;     // Use register for comparison
            end

            7'b0010011: begin    // I-type instructions (addi)
                mem_read = 0;
                mem_write = 0;
                reg_write = 1;
                branch = 0;
                alu_src = 1;     // Use immediate
            end
            
            default: begin       // Invalid instruction
                mem_read = 0;
                mem_write = 0;
                reg_write = 0;
                branch = 0;
                alu_src = 0;
            end
        endcase
    end

endmodule
