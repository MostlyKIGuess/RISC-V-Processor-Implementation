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
        // Format: [31:20] imm | [19:15] rs1 | [14:12] funct3 | [11:7] rd | [6:0] opcode

        cpu.imem.memory[0] = 32'b00000000101000000000000010010011;  // addi x1, x0, 10
                            //   [imm=10]    [rs1=0] [f3=0] [rd=1]  [op=0010011]
        
        cpu.imem.memory[1] = 32'b00000000101100000000000100010011;  // addi x2, x0, 11
                            //   [imm=11]    [rs1=0] [f3=0] [rd=2]  [op=0010011]
        
        // Format: [31:25] funct7 | [24:20] rs2 | [19:15] rs1 | [14:12] funct3 | [11:7] rd | [6:0] opcode

        cpu.imem.memory[2] = 32'b00000000001000001000000110110011;  // add x3, x1, x2
                            //   [f7=0]  [rs2=2] [rs1=1] [f3=0] [rd=3]  [op=0110011]
        
        cpu.imem.memory[3] = 32'b01000000001000001000000100110011;  // sub x4, x1, x2
                            //   [f7=32] [rs2=2] [rs1=1] [f3=0] [rd=4]  [op=0110011]
        
        cpu.imem.memory[4] = 32'b00000000001000001111000101110011;  // and x5, x1, x2
                            //   [f7=0]  [rs2=2] [rs1=1] [f3=7] [rd=5]  [op=0110011]
        
        cpu.imem.memory[5] = 32'b00000000001000001110000110110011;  // or x6, x1, x2
                            //   [f7=0]  [rs2=2] [rs1=1] [f3=6] [rd=6]  [op=0110011]
        
        // Format: [31:25] imm[11:5] | [24:20] rs2 | [19:15] rs1 | [14:12] funct3 | [11:7] imm[4:0] | [6:0] opcode

        cpu.imem.memory[6] = 32'b00000000001100010011000000100011;  // sd x3, 0(x2)
                            //   [imm=0]    [rs2=3] [rs1=2] [f3=3] [imm=0]   [op=0100011]
        
        // Format: [31:20] imm | [19:15] rs1 | [14:12] funct3 | [11:7] rd | [6:0] opcode

        cpu.imem.memory[7] = 32'b00000000000100010011000111000011;  // ld x7, 0(x2)
                            //   [imm=0]    [rs1=2] [f3=3] [rd=7]  [op=0000011]
        
        // Format: [31:25] imm[12|10:5] | [24:20] rs2 | [19:15] rs1 | [14:12] funct3 | [11:7] imm[4:1|11] | [6:0] opcode

        cpu.imem.memory[8] = 32'b00000000001000001000010001100011;  // beq x1, x2, 8
                            //   [imm=0]     [rs2=2] [rs1=1] [f3=0] [imm=8]    [op=1100011]
    end
    
    integer i;
    initial begin
        // waveforms
        $dumpfile("test_results/cpu_sequential_test.vcd");
        $dumpvars(0, testbench_sequential);
        
        @(negedge reset);
        
        repeat(8) @(posedge clk);
        
        $display("Register file contents:");
        for(i = 0; i < 8; i = i + 1) begin
            $display("x%0d = %0d [0x%h]", i, cpu.reg_file.registers[i], cpu.reg_file.registers[i]);
        end

        // memory
        $display("\nMemory contents:");
        $display("mem[0] = %0d [0x%h]", cpu.dmem.memory[0], cpu.dmem.memory[0]);
                
        
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
                cpu.rs1, cpu.rs2, {{52{cpu.instruction[31]}}, cpu.instruction[7:0], 2'b0});
        endcase

        // registers getting used
        $display("Register values:");
        $display("rs1(x%0d)=%0d", cpu.rs1, cpu.reg_file.registers[cpu.rs1]);
        $display("rs2(x%0d)=%0d", cpu.rs2, cpu.reg_file.registers[cpu.rs2]);
        if (cpu.reg_write)
            $display("Writing to rd(x%0d)=%0d [0x%h]", cpu.rd, cpu.reg_write_data, cpu.reg_write_data);
        
        // control signals
        $display("Control signals:");
        $display("reg_write=%b, mem_read=%b, mem_write=%b, branch=%b", 
            cpu.reg_write, cpu.mem_read, cpu.mem_write, cpu.branch);
        
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
