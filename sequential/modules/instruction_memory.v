module instruction_memory(
    input [63:0] pc,
    output reg [31:0] instruction
);
    reg [31:0] memory [0:1023]; // 1024 max instructions
    
    always @(*) begin
        if (pc[11:2] > 1023) begin
            $fatal(1, "Error: Invalid instruction address %d (out of range)", pc);
        end else begin
            instruction = memory[pc[11:2]]; // Access instruction memory (byte-aligned)
        end
    end

endmodule
