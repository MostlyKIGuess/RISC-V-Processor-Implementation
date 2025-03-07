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
        cpu.imem.memory[0] = 32'b00000000000100000000001000010011;
        cpu.imem.memory[1] = 32'b00000000000100000000010000010011;
        cpu.imem.memory[2] = 32'b00000000000100000000010000010011;
        cpu.imem.memory[3] = 32'b00000000010000000000010001100011;
        cpu.imem.memory[4] = 32'b00000000010000000000001100010011;
        cpu.imem.memory[5] = 32'b00000000010000000000001010010011;
        cpu.imem.memory[6] = 32'b11111111111111111111111111111111;
        
        // promper initialization
        #10 reset = 0;
        
        forever #15 clk = ~clk; 
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
                cpu.rs1, cpu.reg_read_data1, cpu.rs2, cpu.reg_read_data2, cpu.rd);
            
            // Show EX stage activity (removed alu_control as it doesn't exist)
            $display("EX Stage: ALU Result=%0h", cpu.alu_result);
            
            // Show MEM stage activity
            if (cpu.mem_write)
                $display("MEM Stage: Writing %0d to address %0d", 
                    cpu.reg_read_data2, cpu.alu_result);
            if (cpu.mem_read)
                $display("MEM Stage: Reading from address %0d, value=%0d", 
                    cpu.alu_result, cpu.mem_read_data);
                
            // Show WB stage activity
            if (cpu.reg_write && cpu.rd != 0)
                $display("WB Stage: Writing %0d to register x%0d", 
                    cpu.reg_write_data, cpu.rd);
            
            // Control signals
            $display("Control signals: branch=%b, mem_read=%b, mem_to_reg=%b, mem_write=%b, alu_src=%b, reg_write=%b", 
                cpu.branch, cpu.mem_read, cpu.mem_to_reg, cpu.mem_write, cpu.alu_src, cpu.reg_write);
            
        end
    end
    
endmodule