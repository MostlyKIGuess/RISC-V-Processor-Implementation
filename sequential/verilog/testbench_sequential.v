`timescale 1ns/1ps

module testbench_sequential();
    reg clk;
    reg reset;

    integer cycle_count = 0;
    real execution_time;
    real execution_time_ms;
    real execution_time_us;
    integer execution_time_p;
    
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
        cpu.imem.memory[0] = 32'b00000000001100000000000010010011;
        cpu.imem.memory[1] = 32'b00000000011100000000000100010011;
        cpu.imem.memory[2] = 32'b00000000000000001000100001100011;
        cpu.imem.memory[3] = 32'b00000000000100010000000100110011;
        cpu.imem.memory[4] = 32'b11111111111100001000000010010011;
        cpu.imem.memory[5] = 32'b11111110000000000000101011100011;
        cpu.imem.memory[6] = 32'b00000000000000000000000000000000;
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

    
    /// signals boi  LLMs ki jai ho for formatting
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
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