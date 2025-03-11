`timescale 1ns/1ps

module testbench_pipelined();
    reg clk;
    reg reset;
    wire end_program;

    integer cycle_count = 0;
    real execution_time;
    real execution_time_ms;
    real execution_time_us;
    integer execution_time_p;
        
    initial begin
        clk = 0;
        reset = 1;
        
        // Initialize instruction memory first
        cpu.imem.memory[0] = 32'b00000000101000000000000010010011;
        cpu.imem.memory[1] = 32'b00000000000000000000000100010011;
        cpu.imem.memory[2] = 32'b00000000000100000000000110010011;
        cpu.imem.memory[3] = 32'b00000010000000001000010001100011;
        cpu.imem.memory[4] = 32'b11111111111100001000000010010011;
        cpu.imem.memory[5] = 32'b00000000000000001000111001100011;
        cpu.imem.memory[6] = 32'b00000000001100010000001000110011;
        cpu.imem.memory[7] = 32'b00000000000000011000000100110011;
        cpu.imem.memory[8] = 32'b00000000000000100000000110110011;
        cpu.imem.memory[9] = 32'b11111111111100001000000010010011;
        cpu.imem.memory[10] = 32'b00000000000000001000010001100011;
        cpu.imem.memory[11] = 32'b11111110000000000000011011100011;
        cpu.imem.memory[12] = 32'b00000000000000011000001000110011;
        cpu.imem.memory[13] = 32'b00000000000000000000000000010011;
        cpu.imem.memory[14] = 32'b00000000000000000000000000000000;
        
        // promper initialization
        #10 reset = 0;
        
        forever #5 clk = ~clk; 
    end
    
    cpu_pipelined cpu(
        .clk(clk),
        .reset(reset),
        .end_program(end_program)
    );
        
    integer i;
    initial begin
        $dumpfile("test_results/cpu_pipelined_test.vcd");
        $dumpvars(0, testbench_pipelined);
        
        @(negedge reset);

        // Run simulation until end_program is high
        while (!end_program) begin
            @(posedge clk);
        end
        
        // Allow pipeline to flush completely
        repeat (5) @(posedge clk);

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

        execution_time = cycle_count * 10e-9; // Convert cycles to seconds
        execution_time_ms = cycle_count * 10e-6; // Convert cycles to milliseconds
        execution_time_us = cycle_count * 10e-3; // Convert cycles to microseconds
        execution_time_p = cycle_count * 10000; // Convert cycles to picoseconds

        $display("\nTotal Execution Time:");
        $display("Seconds: %0.9f s", execution_time);
        $display("Milliseconds: %0.6f ms", execution_time_ms);
        $display("Microseconds: %0.3f µs", execution_time_us);
        $display("Picoseconds: %0d ps", execution_time_p);

        $finish;
    end
    
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
            $display("--------------------------------");
            $display("Time=%0t, Cycle=%0d", $time, cycle_count);
            
            $display("PIPELINE STATE:");
            $display("IF Stage: PC=%h, Instruction=%h", cpu.pc_current, cpu.instruction);
            
            // Decode current instruction in IF stage
            if (cpu.instruction != 0) begin
                case(cpu.instruction[6:0])
                    7'b0110011: begin // R-type 
                        case(cpu.instruction[14:12])
                            3'b000: begin
                                if (cpu.instruction[31:25] == 7'b0000000)
                                    $display("IF: add x%0d, x%0d, x%0d", 
                                        cpu.instruction[11:7], cpu.instruction[19:15], cpu.instruction[24:20]);
                                else
                                    $display("IF: sub x%0d, x%0d, x%0d", 
                                        cpu.instruction[11:7], cpu.instruction[19:15], cpu.instruction[24:20]);
                            end
                            3'b111: $display("IF: and x%0d, x%0d, x%0d", 
                                cpu.instruction[11:7], cpu.instruction[19:15], cpu.instruction[24:20]);
                            3'b110: $display("IF: or x%0d, x%0d, x%0d", 
                                cpu.instruction[11:7], cpu.instruction[19:15], cpu.instruction[24:20]);
                        endcase
                    end
                    7'b0000011: $display("IF: ld x%0d, %0d(x%0d)", 
                        cpu.instruction[11:7], $signed({{52{cpu.instruction[31]}}, cpu.instruction[31:20]}), cpu.instruction[19:15]);
                    7'b0100011: $display("IF: sd x%0d, %0d(x%0d)", 
                        cpu.instruction[24:20], $signed({{52{cpu.instruction[31]}}, cpu.instruction[31:25], cpu.instruction[11:7]}), cpu.instruction[19:15]);
                    7'b1100011: $display("IF: beq x%0d, x%0d, %0d", 
                        cpu.instruction[19:15], cpu.instruction[24:20], 
                        $signed({{51{cpu.instruction[31]}}, cpu.instruction[7], cpu.instruction[30:25], cpu.instruction[11:8], 1'b0}));
                    7'b0010011: $display("IF: addi x%0d, x%0d, %0d",
                        cpu.instruction[11:7], cpu.instruction[19:15], 
                        $signed({{52{cpu.instruction[31]}}, cpu.instruction[31:20]}));
                endcase
            end

            // Show ID stage activity
            $display("ID Stage: rs1=x%0d (%0d), rs2=x%0d (%0d), rd=x%0d", 
                cpu.rs1, cpu.reg_read_data1, cpu.rs2, cpu.reg_read_data2, cpu.reg_rd);
            
            // Show EX stage activity
            $display("EX Stage: ALU Result=%0h", cpu.alu_result);
            
            // Show MEM stage activity
            if (cpu.mem_write)
                $display("MEM Stage: Writing %0d to address %0d", 
                    cpu.reg_read_data2, cpu.alu_result);
            if (cpu.mem_read)
                $display("MEM Stage: Reading from address %0d, value=%0d", 
                    cpu.alu_result, cpu.mem_read_data);
                
            // Show WB stage activity
            if (cpu.reg_write && cpu.reg_rd != 0)
                $display("WB Stage: Writing %0d to register x%0d", 
                    cpu.reg_write_data, cpu.reg_rd);
            
            // Control signals
            $display("Control signals: branch=%b, mem_read=%b, mem_to_reg=%b, mem_write=%b, alu_src=%b, reg_write=%b", 
                cpu.branch, cpu.mem_read, cpu.mem_to_reg, cpu.mem_write, cpu.alu_src, cpu.reg_write);
            
            // Add pipeline register contents - MORE DETAILED INFO
            $display("Pipeline Registers:");
            $display("IF/ID: PC=%h, Instruction=%h", cpu.if_id_pc, cpu.if_id_instruction);
            $display("ID/EX: PC=%h, Instruction=%h, rs1=x%0d, rs2=x%0d, rd=x%0d, RegWrite=%b, MemWrite=%b", 
                     cpu.id_ex_pc, cpu.id_ex_instruction, cpu.id_ex_rs1, cpu.id_ex_rs2, 
                     cpu.id_ex_rd, cpu.id_ex_reg_write, cpu.id_ex_mem_write);
            $display("EX/MEM: Instruction=%h, rd=x%0d, RegWrite=%b, MemWrite=%b, ALUResult=%h", 
                     cpu.ex_mem_instruction, cpu.ex_mem_rd, cpu.ex_mem_reg_write, 
                     cpu.ex_mem_mem_write, cpu.ex_mem_alu_result);
            $display("MEM/WB: Instruction=%h, rd=x%0d, RegWrite=%b, MemToReg=%b", 
                     cpu.mem_wb_instruction, cpu.mem_wb_rd, cpu.mem_wb_reg_write, 
                     cpu.mem_wb_mem_to_reg);
            $display("Register Values:");
            for (i = 0; i < 32; i = i + 1) begin
                $display("reg[%0d]=%0d", i, cpu.reg_file.registers[i]);
            end
                        
                // Hazard detection information
                if (cpu.stall) begin  // Use cpu.stall directly instead of cpu.hazard_detection_unit.stall_pipeline
                    $display("HAZARD DETECTED: Stalling pipeline");
                    $display("Load-use hazard between instructions at PC=%h and PC=%h", 
                            cpu.if_id_pc - 4, cpu.if_id_pc);
                end

                // Forwarding information
                if (cpu.forwardA != 0 || cpu.forwardB != 0) begin  // Use cpu.forwardA/B directly
                    $display("Forwarding active:");
                    if (cpu.forwardA == 2'b10)
                        $display("EX → EX Forwarding to rs1 (x%0d)", cpu.id_ex_rs1);
                    if (cpu.forwardA == 2'b01)
                        $display("MEM → EX Forwarding to rs1 (x%0d)", cpu.id_ex_rs1);
                    if (cpu.forwardB == 2'b10)
                        $display("EX → EX Forwarding to rs2 (x%0d)", cpu.id_ex_rs2);
                    if (cpu.forwardB == 2'b01)
                        $display("MEM → EX Forwarding to rs2 (x%0d)", cpu.id_ex_rs2);
                end

                // Branch information
                if (cpu.branch && cpu.zero) begin  // Use cpu.zero instead of cpu.alu_zero
                    $display("Branch at PC=%h: Taking branch", cpu.pc_current);
                    if (cpu.branch_mispredicted)  // Use cpu.branch_mispredicted directly
                        $display("Branch mispredicted: Pipeline flush required");
                end

                // Pipeline stall/flush status
                if (cpu.flush)  // Use cpu.flush instead of cpu.if_id_flush
                    $display("Pipeline flushed");
        end
    end
    
endmodule