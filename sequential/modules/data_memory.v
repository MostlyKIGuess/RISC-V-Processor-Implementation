module data_memory(
    input clk,
    input [63:0] address,
    input signed [63:0] write_data,
    input mem_read,
    input mem_write,
    output reg signed [63:0] read_data
);
    reg [7:0] memory [0:1023]; // 1KB memory
    
    always @(posedge clk) begin
        if (mem_write)
            {memory[address+7], memory[address+6], memory[address+5], memory[address+4],
             memory[address+3], memory[address+2], memory[address+1], memory[address]} <= write_data;
    end
    
    always @(*) begin
        if (mem_read)
            read_data = {memory[address+7], memory[address+6], memory[address+5], memory[address+4],
                        memory[address+3], memory[address+2], memory[address+1], memory[address]};
    end
endmodule
