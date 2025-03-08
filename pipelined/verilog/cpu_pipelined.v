`timescale 1ns/1ps

`include "modules/misc/mux3to1.v"
`include "modules/alu.v"
`include "modules/program_counter.v"
`include "modules/instruction_memory.v"
`include "modules/register_file.v"
`include "modules/data_memory.v"
`include "modules/control_unit.v"
`include "modules/immediate_gen.v"
`include "modules/fetch_decode_register.v"
`include "modules/decode_execute_register.v"
`include "modules/execute_memory_register.v"
`include "modules/memory_writeback_register.v"
`include "modules/hazard_unit.v"


module cpu_pipelined(
    input clk,                  
    input reset,
    output end_program           
);
    wire [63:0] pc, pc_fetch;

    program_counter pc_(
        .clk(clk),
        .reset(reset),
        .enable(~stallF),
        .next_pc(pc),
        .pc(pc_fetch)
    );

    wire [63:0] pc_4fetch;
    assign pc_4fetch = pc_fetch + 4;

    assign pc = pc_src_decode ? pc_branch_decode : pc_4fetch;

    wire [31:0] instr_fetch;

    instruction_memory imem(
        .address(pc_fetch),
        .instruction(instr_fetch)
    );

    wire eop, eop_decode, eop_execute, eop_memory, eop_writeback;
    assign eop = instr_fetch == -1;

    wire [31:0] instr_decode;
    wire [63:0] pc_decode;

    fetch_decode_register f_d_reg(
        .clk(clk),
        .reset(reset),
        .flush(pc_src_decode),
        .enable(~stallD),
        .d({pc_fetch , instr_fetch , eop}),
        .q({pc_decode, instr_decode, eop_decode})
    );
    
    wire [4:0] rs1_decode, rs2_decode;
    wire [63:0] read_data1_decode, read_data2_decode;

    assign rs1_decode = instr_decode[19:15];
    assign rs2_decode = instr_decode[24:20];

    register_file reg_file(
        .clk(clk),
        .reg_write(reg_write_writeback),
        .rs1(rs1_decode),
        .rs2(rs2_decode),
        .rd(rd_writeback),
        .read_data1(read_data1_decode),
        .read_data2(read_data2_decode),
        .write_data(result_writeback)
    );

    wire [63:0] immed_decode;

    immediate_gen immed_gen(
        .instruction(instr_decode),
        .immediate_extended(immed_decode)
    );

    wire branch_decode, mem_to_reg_decode, mem_write_decode, alu_src_decode, reg_write_decode;

    control_unit ctrl(
        .instruction(instr_decode),
        .branch(branch_decode),
        .mem_to_reg(mem_to_reg_decode),
        .mem_write(mem_write_decode),
        .alu_src(alu_src_decode),
        .reg_write(reg_write_decode)
    );

    wire pc_src_decode;
    wire [63:0] pc_branch_decode, shifted_immed;
    assign pc_src_decode = branch_decode & ((forwardAD ? alu_result_memory : read_data1_decode) == (forwardBD ? alu_result_memory : read_data2_decode));
    assign shifted_immed = immed_decode << 1;
    assign pc_branch_decode = pc_decode + shifted_immed;

    decode_execute_register d_e_reg(
        .clk(clk),
        .reset(reset),
        .flush(flushE),
        .d({read_data1_decode,  read_data2_decode , immed_decode , instr_decode , pc_decode , branch_decode , mem_to_reg_decode , mem_write_decode , alu_src_decode , reg_write_decode , eop_decode}),
        .q({read_data1_execute, read_data2_execute, immed_execute, instr_execute, pc_execute, branch_execute, mem_to_reg_execute, mem_write_execute, alu_src_execute, reg_write_execute, eop_execute})
    );

    wire alu_src_execute;
    wire [31:0] instr_execute;
    wire [63:0] read_data1_execute, read_data2_execute, immed_execute, alu_result_execute, pc_execute;

    wire [63:0] forwarding_AE, forwarding_BE;

    mux3to1 alu_in1(
        .in0(read_data1_execute),
        .in1(result_writeback),
        .in2(alu_result_memory),
        .sel(forwardAE),
        .out(forwarding_AE)
    );

    mux3to1 alu_in2(
        .in0(read_data2_execute),
        .in1(result_writeback),
        .in2(alu_result_memory),
        .sel(forwardBE),
        .out(forwarding_BE)
    );

    alu main_alu(
        .instruction(instr_execute),
        .in1(forwarding_AE),
        .in2(alu_src_execute ? immed_execute : forwarding_BE),
        .out(alu_result_execute)
    );

    wire branch_execute, mem_to_reg_execute, mem_write_execute, reg_write_execute;

    execute_memory_register e_m_reg(
        .clk(clk),
        .reset(reset),
        .d({alu_result_execute, forwarding_BE    , instr_execute, branch_execute, mem_to_reg_execute, mem_write_execute, reg_write_execute, eop_execute}),
        .q({alu_result_memory , write_data_memory, instr_memory , branch_memory , mem_to_reg_memory , mem_write_memory , reg_write_memory , eop_memory})
    );

    wire mem_read_memory, mem_write_memory, mem_to_reg_memory, reg_write_memory;
    wire [31:0] instr_memory;
    wire [63:0] alu_result_memory, write_data_memory, result_memory, data_result_memory;

    data_memory dmem(
        .clk(clk),
        .address(alu_result_memory),
        .write_data(write_data_memory),
        .read_data(data_result_memory),
        .mem_read(reg_write_memory),
        .mem_write(mem_write_memory)
    );

    memory_writeback_register m_w_reg(
        .clk(clk),
        .reset(reset),
        .d({alu_result_memory   , data_result_memory   , instr_memory   , reg_write_memory   , mem_to_reg_memory   , eop_memory}),
        .q({alu_result_writeback, data_result_writeback, instr_writeback, reg_write_writeback, mem_to_reg_writeback, eop_writeback})
    );

    wire mem_to_reg_writeback, reg_write_writeback;
    wire [4:0] rd_writeback;
    wire [31:0] instr_writeback;
    wire [63:0] data_result_writeback, alu_result_writeback, result_writeback;

    assign result_writeback = mem_to_reg_writeback ? data_result_writeback : alu_result_writeback;
    assign rd_writeback = instr_writeback[11:7];

    assign end_program = eop_writeback;

    wire [1:0] forwardAE, forwardBE;
    wire stallF, stallD, flushE;
    wire forwardAD, forwardBD;

    hazard_unit haz(
        
        .rs1E(instr_execute[19:15]),
        .rs2E(instr_execute[24:20]),
        .write_regM(instr_memory[11:7]),
        .write_regW(instr_writeback[11:7]),
        .reg_writeM(reg_write_memory),
        .reg_writeW(reg_write_writeback),
        .forwardAE(forwardAE),
        .forwardBE(forwardBE),

        .rs1D(rs1_decode),
        .rs2D(rs2_decode),
        .rdE(instr_execute[11:7]),
        .mem_to_regE(mem_to_reg_execute),
        .stallF(stallF),
        .stallD(stallD),
        .flushE(flushE),

        .branchD(branch_decode),
        .reg_writeE(reg_write_execute),
        .mem_to_regM(mem_to_reg_memory),
        .forwardAD(forwardAD),
        .forwardBD(forwardBD)

    );

endmodule