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
        cpu.imem.memory[0] = 32'b00000000000000000010000100000011;
        cpu.imem.memory[1] = 32'b00000000000100010000001000010011;
        cpu.imem.memory[2] = 32'b00000000001000010000010000010011;
        cpu.imem.memory[3] = 32'b00000000001000100000010010110011;
        cpu.imem.memory[4] = 32'b11111111111111111111111111111111;
        
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

    
endmodule