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
    // Pipeline registers outputs
    wire [63:0] ex_mem_pc;
    wire [63:0] ex_mem_alu_result;
    wire [63:0] ex_mem_reg_read_data2;
    wire [63:0] ex_mem_branch_target;
    wire [31:0] ex_mem_instruction;
    wire ex_mem_zero;
    wire ex_mem_branch;
    wire ex_mem_mem_read;
    wire ex_mem_mem_write;
    wire ex_mem_mem_to_reg;
    wire ex_mem_reg_write;
    wire ex_mem_nop_instruction;
    
    wire [63:0] mem_wb_mem_read_data;
    wire [63:0] mem_wb_alu_result;
    wire [31:0] mem_wb_instruction;
    wire mem_wb_mem_to_reg;
    wire mem_wb_reg_write;
    wire mem_wb_nop_instruction;

    // Branch prediction and handling signals
    wire branch_predicted;
    wire [63:0] predicted_pc;
    wire branch_mispredicted;
    wire flush;

    // Program Counter
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

    // Modified branch prediction and handling logic
    wire is_branch = (instruction[6:0] == 7'b1100011);
    wire [63:0] if_branch_offset = {{51{instruction[31]}}, 
                                instruction[31],
                                instruction[7],
                                instruction[30:25],
                                instruction[11:8],
                                1'b0};
    wire [63:0] if_branch_target = pc_current + if_branch_offset;

    // Always predict taken for branches
    assign branch_predicted = is_branch;
    // Key change: Use branch prediction only for branch instructions
    assign predicted_pc = branch_predicted ? if_branch_target : (pc_current + 4);

    
    wire nop_instruction;
    assign nop_instruction = (instruction == 32'b0);
    
    // IF/ID Pipeline Register
    wire [63:0] if_id_pc;
    wire [31:0] if_id_instruction;
    wire if_id_nop_instruction;
    wire if_id_branch_predicted;
    wire [63:0] if_id_predicted_pc;
    
    wire [31:0] instr_to_use = flush ? 32'h00000013 : instruction;  // NOP when flush

    if_id_register if_id(
        .clk(clk),
        .reset(reset | flush),
        // No stall on branch taken to ensure target instruction proceeds
        .en(~stall | branch_predicted),
        .d({pc_current, instr_to_use, nop_instruction, branch_predicted, predicted_pc}),
        .q({if_id_pc, if_id_instruction, if_id_nop_instruction, if_id_branch_predicted, if_id_predicted_pc})
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
    
    register_file reg_file(
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(reg_rd),
        .write_data(reg_write_data),
        .reg_write(mem_wb_reg_write),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );

    // ID/EX Pipeline Register
    wire [63:0] id_ex_pc, id_ex_reg_read_data1, id_ex_reg_read_data2;
    wire [31:0] id_ex_instruction;
    wire id_ex_branch, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg;
    wire id_ex_reg_write, id_ex_alu_src, id_ex_nop_instruction;
    wire id_ex_branch_predicted;
    wire [63:0] id_ex_predicted_pc;

    wire [4:0] id_ex_rd = id_ex_instruction[11:7];
    wire load_hazard = id_ex_mem_read & 
                     ((id_ex_rd == rs1) | (id_ex_rd == rs2)) &
                     (id_ex_rd != 0);
    wire stall = load_hazard;

    id_ex_register id_ex(
        .clk(clk),
        .reset(reset | flush),
        .en(~stall),
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
            if_id_nop_instruction,
            if_id_branch_predicted,
            if_id_predicted_pc
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
            id_ex_nop_instruction,
            id_ex_branch_predicted,
            id_ex_predicted_pc
        })
    );

    // Forwarding Logic (EX stage)
    reg [1:0] forwardA, forwardB;
    wire [4:0] ex_mem_rd = ex_mem_instruction[11:7];
    wire [4:0] mem_wb_rd = mem_wb_instruction[11:7];
    wire [4:0] id_ex_rs1 = id_ex_instruction[19:15];
    wire [4:0] id_ex_rs2 = id_ex_instruction[24:20];

    always @(*) begin
        forwardA = 2'b00;
        if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1)
            forwardA = 2'b10;
        else if (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs1)
            forwardA = 2'b01;
    end

    always @(*) begin
        forwardB = 2'b00;
        if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2)
            forwardB = 2'b10;
        else if (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs2)
            forwardB = 2'b01;
    end

    // ALU Operand Forwarding
    wire signed [63:0] ex_forward_value = ex_mem_alu_result;
    wire signed [63:0] mem_forward_value = mem_wb_mem_to_reg ? mem_wb_mem_read_data : mem_wb_alu_result;

    reg signed [63:0] operandA;
    always @(*) begin
        case (forwardA)
            2'b10: operandA = ex_forward_value;
            2'b01: operandA = mem_forward_value;
            default: operandA = id_ex_reg_read_data1;
        endcase
    end

    reg signed [63:0] operandB;
    always @(*) begin
        case (forwardB)
            2'b10: operandB = ex_forward_value;
            2'b01: operandB = mem_forward_value;
            default: operandB = id_ex_reg_read_data2;
        endcase
    end

    // Immediate Generation
    wire [63:0] imm_val;
    
    // I-type immediate
    wire [63:0] i_imm = {{53{id_ex_instruction[31]}}, id_ex_instruction[30:20]};
    // S-type immediate
    wire [63:0] s_imm = {{53{id_ex_instruction[31]}}, id_ex_instruction[30:25], id_ex_instruction[11:7]};
    // B-type immediate
    wire [63:0] b_imm = {{51{id_ex_instruction[31]}}, id_ex_instruction[31], id_ex_instruction[7], 
                         id_ex_instruction[30:25], id_ex_instruction[11:8], 1'b0};
    
    assign imm_val = (id_ex_instruction[6:0] == 7'b0010011 || id_ex_instruction[6:0] == 7'b0000011) ? i_imm :
                     (id_ex_instruction[6:0] == 7'b0100011) ? s_imm :
                     (id_ex_instruction[6:0] == 7'b1100011) ? b_imm : 64'h0;

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

    // Branch Target Calculation (EX stage)
    wire [63:0] branch_target = id_ex_pc + b_imm;

    // Branch condition checking
    wire branch_eq = id_ex_branch & (id_ex_instruction[14:12] == 3'b000);  // BEQ
    wire branch_ne = id_ex_branch & (id_ex_instruction[14:12] == 3'b001);  // BNE
    wire branch_lt = id_ex_branch & (id_ex_instruction[14:12] == 3'b100);  // BLT
    wire branch_ge = id_ex_branch & (id_ex_instruction[14:12] == 3'b101);  // BGE

    // branch logic
    wire branch_taken = (branch_eq & zero) |
                        (branch_ne & ~zero) |
                        (branch_lt & (operandA < operandB)) |
                        (branch_ge & (operandA >= operandB));

    // Branch misprediction detection
    assign branch_mispredicted = id_ex_branch && (branch_taken != id_ex_branch_predicted);
    
    // Correct address when mispredicted
    wire [63:0] correct_pc = branch_taken ? branch_target : (id_ex_pc + 4);
    
    // Flush pipeline on misprediction
    assign flush = branch_mispredicted & ~id_ex_branch_predicted;

    // 2. Fix PC selection logic - ensure branch target instructions proceed correctly
    wire [63:0] pc_to_use = stall ? pc_current : 
                        (branch_mispredicted ? correct_pc : predicted_pc);
    assign pc_next = pc_to_use;


    // EX/MEM Pipeline Register
    ex_mem_register ex_mem(
        .clk(clk),
        .reset(reset),
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
    mem_wb_register mem_wb(
        .clk(clk),
        .reset(reset),
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

    // Write-Back Stage
    assign reg_write_data = mem_wb_mem_to_reg ? mem_wb_mem_read_data : mem_wb_alu_result;
    wire [4:0] mem_wb_rd_fixed = mem_wb_instruction[11:7];
    assign reg_rd = mem_wb_rd_fixed;

    // End of Program
    assign end_program = mem_wb_nop_instruction & ~ branch_predicted;

endmodule
