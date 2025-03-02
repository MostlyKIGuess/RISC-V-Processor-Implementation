`timescale 1ns/1ps

`include "modules/alu.v"
`include "modules/program_counter.v"
`include "modules/instruction_memory.v"
`include "modules/register_file.v"
`include "modules/data_memory.v"
`include "modules/control_unit.v"

module cpu_sequential(
    input clk,                  
    input reset                 
);
    // program counter wale baba
    wire [63:0] pc_next;        
    wire [63:0] pc_current;     
    
    // branch instruction ke liye
    wire [63:0] branch_target;  // jump kaha karna hai
    wire branch_taken;          // jump karna hai ya nahi
    
    // instruction fetch se aaya hua
    wire [31:0] instruction;    
    
    // control signals - CPU ko batate hai kya karna hai
    wire mem_read;              // memory se padhna hai
    wire mem_write;             // memory me likhna hai
    wire mem_to_reg;            // memory se ya ALU se value aayi hai
    wire reg_write;             // register me value store karni hai
    wire branch;                // branch instruction hai ya nahi
    wire alu_src;               // ALU me register ya immediate value use karni hai
    
    // register file ke signals
    wire [4:0] rs1;            // sourcereg
    wire [4:0] rs2;            // sourcereg
    wire [4:0] rd;             // destination regi
    wire signed [63:0] reg_write_data;    
    wire signed [63:0] reg_read_data1;    
    wire signed [63:0] reg_read_data2;    
    
    // ALU ke signals
    wire signed [63:0] alu_result;     // ALU ka final answer
    wire signed [63:0] alu_operand2;   // ALU ka dusra input (reg ya immediate value)
    wire zero;                        // ALU ka zero flag
    
    // memory ke signals
    wire signed [63:0] mem_read_data;  // memory se padhi hui value

    // Program Counter - instruction address ko track karta hai
    program_counter pc(
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),      // agli instruction ka address
        .pc(pc_current)         // current instruction ka address
    );

    // program instructions ko store karta hai
    instruction_memory imem( // REMEMBER INITIALIZED AS imem, so you can do cpu.imem.memory[0] in testbench
        .pc(pc_current),         // current PC se
        .instruction(instruction) // instruction nikalo
    );

    control_unit ctrl(
        .instruction(instruction),  // instruction decode karke
        .branch(branch),            // branch instruction hai ya nahi
        .mem_read(mem_read),        // memory se padhna hai
        .mem_to_reg(mem_to_reg),    // memory se ya ALU se value aayi hai
        .mem_write(mem_write),      // memory me likhna hai
        .alu_src(alu_src),          // ALU me register ya immediate value use karni hai
        .reg_write(reg_write)       // register me value store karni hai
    );

    // Register File ke inputs set karo
    assign rs1 = instruction[19:15];  // source register 1 ka number
    assign rs2 = instruction[24:20];  // source register 2 ka number
    assign rd = instruction[11:7];    // destination register ka number

    // Register File - CPU ke registers ko handle karta hai
    register_file reg_file(
        .clk(clk),
        .rs1(rs1),                    // pehla source register
        .rs2(rs2),                    // dusra source register
        .rd(rd),                      // destination register
        .write_data(reg_write_data),  // jo value likhni hai
        .reg_write(reg_write),        // write enable signal
        .read_data1(reg_read_data1),  // pehle register ki value
        .read_data2(reg_read_data2)   // dusre register ki value
    );

    // ALU ka dusra operand select karo
    assign alu_operand2 = alu_src ? {{53{instruction[31]}}, instruction[30:20]} : reg_read_data2;  // immediate ya register value

    // ALU - actual calculation karta hai
    alu main_alu(
        .instruction(instruction),     // instruction decode karke
        .in1(reg_read_data1),         // pehla operand
        .in2(alu_operand2),           // dusra operand
        .out(alu_result),            // result nikalo
        .zero(zero)
    );

    // PC update kaise hoga -> branch ke hisab se
    assign branch_target = pc_current + {{51{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // calculate branch target
    assign branch_taken = branch & zero;                    // branch lena hai ya nahi
    assign pc_next = branch_taken ? branch_target : pc_current + 4;                       // next PC set karo

    // Data Memory - data store karne ke liye
    data_memory dmem( // REMEMBER INITIALIZED AS dmem, so you can do cpu.dmem.memory[0] in testbench
        .clk(clk),
        .address(alu_result),         // memory address
        .write_data(reg_read_data2),  // jo data likhna hai
        .mem_read(mem_read),          // read signal
        .mem_write(mem_write),        // write signal
        .read_data(mem_read_data)     // padha hua data
    );

    // register me value write back karo
    assign reg_write_data = mem_to_reg ? mem_read_data : alu_result;  // memory se ya ALU se value select karo

endmodule
