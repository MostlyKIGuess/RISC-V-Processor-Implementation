module data_memory(
    input clk,
    input [63:0] address,
    input signed [63:0] write_data,
    output reg signed [63:0] read_data,
    input mem_read,
    input mem_write,
    input instruction
);
    reg [7:0] memory [0:1023]; // 1KB memory (byte-addressable)

    // Load memory from file at the beginning
    initial begin
        $readmemh("modules/data_memory.hex", memory);
    end

    always @(posedge clk) begin
        if (address > 1016 && mem_write) begin
            $fatal(1, "\n\nError: Invalid memory address %d\n", address);
        end
        if (mem_write && address <= 1016) begin
            memory[address]   <= write_data[7:0];
            memory[address+1] <= write_data[15:8];
            memory[address+2] <= write_data[23:16];
            memory[address+3] <= write_data[31:24];
            memory[address+4] <= write_data[39:32];
            memory[address+5] <= write_data[47:40];
            memory[address+6] <= write_data[55:48];
            memory[address+7] <= write_data[63:56];
        end
    end

    always @(*) begin
        if (address > 1016 && mem_read) begin
            $fatal(1, "\n\nError: Invalid memory address %d\n", address);
        end
        if (mem_read && address <= 1016) begin
            read_data = {memory[address+7], memory[address+6], memory[address+5], memory[address+4],
                         memory[address+3], memory[address+2], memory[address+1], memory[address]};
        end else begin
            read_data = 64'b0;
        end
    end

endmodule
