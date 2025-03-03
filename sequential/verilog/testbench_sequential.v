`timescale 1ns/1ps

module testbench_sequential();
    reg clk;
    reg reset;
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  
    end
    
    initial begin
        reset = 1;
        #15 reset = 0;
    end
    
    cpu_sequential cpu(
        .clk(clk),
        .reset(reset)
    );
    
    initial begin
        cpu.imem.memory[0] = 32'b00000000111100000000000010010011;
        cpu.imem.memory[1] = 32'b00000001100100000000000100010011;
        cpu.imem.memory[2] = 32'b00000000011100000000000110010011;
        cpu.imem.memory[3] = 32'b00000001001000000000001000010011;
        cpu.imem.memory[4] = 32'b00000000001000001000001010110011;
        cpu.imem.memory[5] = 32'b01000000000100010000001100110011;
        cpu.imem.memory[6] = 32'b00000000001100001111001110110011;
        cpu.imem.memory[7] = 32'b00000000001100001110010000110011;
        cpu.imem.memory[8] = 32'b00000000010100000010000000100011;
        cpu.imem.memory[9] = 32'b00000000011000000010010000100011;
        cpu.imem.memory[10] = 32'b00000000000000000010010010000011;
        cpu.imem.memory[11] = 32'b00000000100000000010010100000011;
        cpu.imem.memory[12] = 32'b00000000101001001000010110110011;
        cpu.imem.memory[13] = 32'b01000000101001001000011000110011;
        cpu.imem.memory[14] = 32'b00000000110001011000110001100011;
        cpu.imem.memory[15] = 32'b00000110010000000000011010010011;
        cpu.imem.memory[16] = 32'b00000000110001011110011100110011;
        cpu.imem.memory[17] = 32'b00000000110001011111011110110011;
        cpu.imem.memory[18] = 32'b00000000111000000010100000100011;
        cpu.imem.memory[19] = 32'b00000000111100000010110000100011;
        cpu.imem.memory[20] = 32'b00000011001000000000100000010011;
        cpu.imem.memory[21] = 32'b00000000111110000000100010110011;
        cpu.imem.memory[22] = 32'b01000000111010001000100100110011;
        cpu.imem.memory[23] = 32'b00000001001010001000111001100011;
        cpu.imem.memory[24] = 32'b00000001000000000010100110000011;
        cpu.imem.memory[25] = 32'b00000001100000000010101000000011;
        cpu.imem.memory[26] = 32'b00000001010010011110101010110011;
        cpu.imem.memory[27] = 32'b00000001010010011111101100110011;
        cpu.imem.memory[28] = 32'b00000011010100000010000000100011;
        cpu.imem.memory[29] = 32'b00000011011000000010010000100011;
        cpu.imem.memory[30] = 32'b00000000000000000000000000000000;
    end

    
    integer i;
    initial begin
        $dumpfile("test_results/cpu_sequential_test.vcd");
        $dumpvars(0, testbench_sequential);
        
        @(negedge reset);

        // Run simulation until a NOP (halt)
        while (cpu.instruction !== 32'b0) begin
            @(posedge clk);
        end

        // Print register contents
        $display("Register file contents:");
        for (i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %0d [0x%h]", i, cpu.reg_file.registers[i], cpu.reg_file.registers[i]);
        end

        // Memory contents
        $display("\nMemory contents:");
        for (i = 0; i < 32; i = i + 1) begin
            $display("mem[%0d] = %0d [0x%h]", i, cpu.dmem.memory[i], cpu.dmem.memory[i]);
        end

        $writememh("modules/data_memory.hex", cpu.dmem.memory);
        $display("\nData memory contents written to 'modules/data_memory.hex'");

        $finish;
    end

    
    /// signals boi  LLMs ki jai ho for formatting
    always @(posedge clk) begin
        if (!reset) begin
            $display("\n--------------------------------");
            $display("Time=%0t", $time);
            $display("PC=%h", cpu.pc_current);
            $display("Instruction=%h", cpu.instruction);
            
            case(cpu.instruction[6:0])
                7'b0110011: begin 
                    case(cpu.instruction[14:12])
                        3'b000: $display("Executing: add/sub x%0d, x%0d, x%0d", 
                            cpu.rd, cpu.rs1, cpu.rs2);
                        3'b111: $display("Executing: and x%0d, x%0d, x%0d", 
                            cpu.rd, cpu.rs1, cpu.rs2);
                        3'b110: $display("Executing: or x%0d, x%0d, x%0d", 
                            cpu.rd, cpu.rs1, cpu.rs2);
                    endcase
                end
                7'b0000011: $display("Executing: ld x%0d, %0d(x%0d)", 
                    cpu.rd, {{52{cpu.instruction[31]}}, cpu.instruction[31:20]}, cpu.rs1);
                7'b0100011: $display("Executing: sd x%0d, %0d(x%0d)", 
                    cpu.rs2, {{52{cpu.instruction[31]}}, cpu.instruction[31:20]}, cpu.rs1);
                7'b1100011: $display("Executing: beq x%0d, x%0d, %0d", 
                    cpu.rs1, cpu.rs2, $signed({{51{cpu.instruction[31]}}, cpu.instruction[7], cpu.instruction[30:25], cpu.instruction[11:8]}));
                7'b0010011: $display("Executing: addi x%0d, x%0d, %0d",
                    cpu.rd, cpu.rs1, $signed({{53{cpu.instruction[31]}}, cpu.instruction[30:20]}));
            endcase

            // registers getting used
            $display("Register values:");
            $display("rs1(x%0d)=%0d", cpu.rs1, cpu.reg_file.registers[cpu.rs1]);
            $display("rs2(x%0d)=%0d", cpu.rs2, cpu.reg_file.registers[cpu.rs2]);
            if (cpu.reg_write)
                $display("Writing to rd(x%0d)=%0d [0x%h]", cpu.rd, cpu.reg_write_data, cpu.reg_write_data);
            
            // control signals
            $display("Control signals:");
            $display("branch=%0d, mem_read=%0d, mem_to_reg=%0d, mem_write=%0d, alu_src=%0d, reg_write=%0d", 
                cpu.branch, cpu.mem_read, cpu.mem_to_reg, cpu.mem_write, cpu.alu_src, cpu.reg_write);
            
            // alu result
            $display("ALU result=%0d [0x%h]" , cpu.alu_result, cpu.alu_result);
            
            // memory if read/write
            if (cpu.mem_write)
                $display("Memory write: address=%0d, data=%0d", 
                    cpu.alu_result, cpu.reg_read_data2);
            if (cpu.mem_read)
                $display("Memory read: address=%0d, data=%0d", 
                    cpu.alu_result, cpu.mem_read_data);
        end
    end
    
endmodule