module instruction_memory(
    input [63:0] address,
    output [31:0] instruction
);
    reg [31:0] memory [0:1023]; // 1024 max instructions
    
    assign instruction = memory[address[11:2]]; // 10 bits to address 1024 instructions
endmodule
