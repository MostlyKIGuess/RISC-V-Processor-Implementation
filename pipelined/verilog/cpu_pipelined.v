`timescale 1ns/1ps

`include "modules/alu.v"
`include "modules/program_counter.v"
`include "modules/instruction_memory.v"
`include "modules/register_file.v"
`include "modules/data_memory.v"
`include "modules/control_unit.v"
`include "modules/if_id_register.v"
`include "modules/id_ex_register.v"
`include "modules/ex_mem_register.v"
`include "modules/mem_wb_register.v"

module cpu_pipelined(
    input clk,                  
    input reset,
    output end_program
);
    // Program Counter & PC Logic
    wire [63:0] pc_next;        
    wire [63:0] pc_current;    
    program_counter pc (
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),
        .pc(pc_current)
    );

    // Instruction Fetch
    wire [31:0] instruction;
    instruction_memory imem(
        .pc(pc_current),
        .instruction(instruction)
    );

    wire nop_instruction;
    assign nop_instruction = (instruction == 32'b0);

    // Simple branch handling
    wire take_branch;
    wire flush;
    
    // Branch tracking - simple flag to prevent register writes after branch
    reg branch_was_taken;
    
    initial begin
        branch_was_taken = 1'b0;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            branch_was_taken <= 1'b0;
        else if (take_branch)
            branch_was_taken <= 1'b1;  // Once a branch is taken, set flag permanently
    end

    // IF/ID Pipeline Register
    wire [63:0] if_id_pc;
    wire [31:0] if_id_instruction;
    wire if_id_nop_instruction;
    
    // Insert NOP when flushing
    wire [31:0] instr_to_use = flush ? 32'h00000013 : instruction;  

    if_id_register if_id(
        .clk(clk),
        .reset(reset | flush),
        .en(1'b1),
        .d({pc_current, instr_to_use, nop_instruction}),
        .q({if_id_pc, if_id_instruction, if_id_nop_instruction})
    );

    // Decode (Control Signals)
    wire branch;
    wire mem_read;
    wire mem_to_reg;
    wire mem_write;
    wire alu_src;
    wire reg_write;

    control_unit ctrl(
        .instruction(if_id_instruction),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write)
    );

    // Register File
    wire [4:0] rs1 = if_id_instruction[19:15];
    wire [4:0] rs2 = if_id_instruction[24:20];
    wire [4:0] reg_rd;
    
    wire signed [63:0] reg_write_data;
    wire signed [63:0] reg_read_data1;
    wire signed [63:0] reg_read_data2;

    // Simple check to prevent any register writes after a branch is taken
    wire allow_reg_write = mem_wb_reg_write & ~branch_was_taken;
    
    register_file reg_file(
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(reg_rd),
        .write_data(reg_write_data),
        .reg_write(allow_reg_write),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );

    // ID/EX Pipeline Register
    wire [63:0] id_ex_pc, id_ex_reg_read_data1, id_ex_reg_read_data2;
    wire [31:0] id_ex_instruction;
    wire id_ex_branch, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg;
    wire id_ex_reg_write, id_ex_alu_src, id_ex_nop_instruction;

    id_ex_register id_ex(
        .clk(clk),
        .reset(reset | flush),
        .en(1'b1),
        .d({
            if_id_pc, 
            reg_read_data1, 
            reg_read_data2,
            if_id_instruction, 
            branch, 
            mem_read, 
            mem_write, 
            mem_to_reg, 
            reg_write, 
            alu_src, 
            if_id_nop_instruction
        }),
        .q({
            id_ex_pc, 
            id_ex_reg_read_data1, 
            id_ex_reg_read_data2,
            id_ex_instruction, 
            id_ex_branch, 
            id_ex_mem_read, 
            id_ex_mem_write, 
            id_ex_mem_to_reg, 
            id_ex_reg_write, 
            id_ex_alu_src, 
            id_ex_nop_instruction
        })
    );

    // Forwarding Logic (EX stage)
    reg [1:0] forwardA, forwardB;
    wire [4:0] ex_mem_rd = ex_mem_instruction[11:7];
    wire [4:0] mem_wb_rd = mem_wb_instruction[11:7];

    // Forwarding for ALU operand A
    always @(*) begin
        forwardA = 2'b00;
        
        if (ex_mem_reg_write && (ex_mem_rd != 0) && 
            (ex_mem_rd == id_ex_instruction[19:15])) begin
            forwardA = 2'b10;
        end
        
        if (mem_wb_reg_write && (mem_wb_rd != 0) && 
            (mem_wb_rd == id_ex_instruction[19:15])) begin
            forwardA = 2'b01;
        end
    end

    // Forwarding for ALU operand B
    always @(*) begin
        forwardB = 2'b00;
        
        if (ex_mem_reg_write && (ex_mem_rd != 0) && 
            (ex_mem_rd == id_ex_instruction[24:20])) begin
            forwardB = 2'b10;
        end
        
        if (mem_wb_reg_write && (mem_wb_rd != 0) && 
            (mem_wb_rd == id_ex_instruction[24:20])) begin
            forwardB = 2'b01;
        end
    end

    // ALU & Operand Selection
    wire signed [63:0] ex_forward_value = ex_mem_alu_result;
    wire signed [63:0] mem_forward_value = (mem_wb_mem_to_reg) ? 
                                           mem_wb_mem_read_data : mem_wb_alu_result;

    // MUX for operandA
    reg signed [63:0] operandA;
    always @(*) begin
        case (forwardA)
            2'b10: operandA = ex_forward_value;
            2'b01: operandA = mem_forward_value;
            default: operandA = id_ex_reg_read_data1;
        endcase
    end

    // MUX for operandB
    reg signed [63:0] operandB;
    always @(*) begin
        case (forwardB)
            2'b10: operandB = ex_forward_value;
            2'b01: operandB = mem_forward_value;
            default: operandB = id_ex_reg_read_data2;
        endcase
    end

    // Immediate generation for ALU src
    wire [63:0] imm_val;
    assign imm_val = (id_ex_instruction[6:0] == 7'b0010011 ||
                     id_ex_instruction[6:0] == 7'b0000011)
                    ? {{53{id_ex_instruction[31]}}, id_ex_instruction[30:20]}
                    : {{53{id_ex_instruction[31]}}, id_ex_instruction[30:25], id_ex_instruction[11:7]};
    
    // Select ALU input 2
    wire signed [63:0] alu_in2 = id_ex_alu_src ? imm_val : operandB;

    // ALU
    wire signed [63:0] alu_result;
    wire zero;
    alu main_alu(
        .instruction(id_ex_instruction),
        .in1(operandA),
        .in2(alu_in2),
        .out(alu_result),
        .zero(zero)
    );

    // Branch target calculation
    wire [63:0] branch_target;
    assign branch_target =
        id_ex_pc + {{51{id_ex_instruction[31]}},
                   id_ex_instruction[7],
                   id_ex_instruction[30:25],
                   id_ex_instruction[11:8],
                   1'b0};

    // EX/MEM Pipeline Register
    wire [63:0] ex_mem_pc, ex_mem_alu_result, ex_mem_reg_read_data2, ex_mem_branch_target;
    wire [31:0] ex_mem_instruction;
    wire ex_mem_zero, ex_mem_branch, ex_mem_mem_read, ex_mem_mem_write;
    wire ex_mem_mem_to_reg, ex_mem_reg_write, ex_mem_nop_instruction;

    ex_mem_register ex_mem(
        .clk(clk),
        .reset(reset | flush),
        .en(1'b1),
        .d({
            id_ex_pc,
            alu_result,
            operandB,
            branch_target,
            id_ex_instruction,
            zero,
            id_ex_branch,
            id_ex_mem_read,
            id_ex_mem_write,
            id_ex_mem_to_reg,
            id_ex_reg_write,
            id_ex_nop_instruction
        }),
        .q({
            ex_mem_pc,
            ex_mem_alu_result,
            ex_mem_reg_read_data2,
            ex_mem_branch_target,
            ex_mem_instruction,
            ex_mem_zero,
            ex_mem_branch,
            ex_mem_mem_read,
            ex_mem_mem_write,
            ex_mem_mem_to_reg,
            ex_mem_reg_write,
            ex_mem_nop_instruction
        })
    );

    // Branch handling
    assign take_branch = ex_mem_branch & ex_mem_zero;
    assign flush = take_branch;
    assign pc_next = take_branch ? ex_mem_branch_target : (pc_current + 4);
    
    // Data Memory
    wire signed [63:0] mem_read_data;
    data_memory dmem(
        .clk(clk),
        .address(ex_mem_alu_result),
        .write_data(ex_mem_reg_read_data2),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .read_data(mem_read_data)
    );

    // MEM/WB Pipeline Register
    wire [63:0] mem_wb_mem_read_data, mem_wb_alu_result;
    wire [31:0] mem_wb_instruction;
    wire mem_wb_mem_to_reg, mem_wb_reg_write, mem_wb_nop_instruction;

    mem_wb_register mem_wb(
        .clk(clk),
        .reset(reset | flush),
        .en(1'b1),
        .d({
            mem_read_data,
            ex_mem_alu_result,
            ex_mem_instruction,
            ex_mem_mem_to_reg,
            ex_mem_reg_write,
            ex_mem_nop_instruction
        }),
        .q({
            mem_wb_mem_read_data,
            mem_wb_alu_result,
            mem_wb_instruction,
            mem_wb_mem_to_reg,
            mem_wb_reg_write,
            mem_wb_nop_instruction
        })
    );

    // Write-Back
    assign reg_write_data = mem_wb_mem_to_reg ? mem_wb_mem_read_data : mem_wb_alu_result;
    assign reg_rd = mem_wb_instruction[11:7];

    // End of Program
    assign end_program = mem_wb_nop_instruction;

endmodule
    