module immediate_gen(
    input [31:0] instruction,
    output reg [63:0] immediate_extended
);

    wire [6:0] opcode;
    assign opcode = instruction[6:0];

    always @(*) begin
        case (opcode)
            7'b0010011, 7'b0000011: // I-type
                immediate_extended = {{52{instruction[31]}}, instruction[31:20]}; 

            7'b0100011: // S-type
                immediate_extended = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};

            7'b1100011: // B-type
                immediate_extended = {{52{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8]};

            default:
                immediate_extended = 64'b0;
        endcase
    end

endmodule
