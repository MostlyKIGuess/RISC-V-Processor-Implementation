module control_unit(
    input [31:0] instruction,
    output reg mem_read,
    output reg mem_write,
    output reg reg_write,
    output reg branch
);
    wire [6:0] opcode = instruction[6:0];

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
