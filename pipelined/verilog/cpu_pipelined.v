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

    // Branch prediction ke signals
    wire branch_predicted;
    wire [63:0] predicted_pc;
    wire branch_mispredicted;
    wire flush;

    // Ye ek-cycle stall ka flag hai - load hazard ke liye important hai
    reg stalled_last_cycle;
    
    // Program Counter - instruction address track karta hai 
    wire [63:0] pc_next;        
    wire [63:0] pc_current;    
    program_counter pc (
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),
        .pc(pc_current)
    );

    // Instruction Fetch - memory se instruction lata hai
    wire [31:0] instruction;
    instruction_memory imem(
        .pc(pc_current),
        .instruction(instruction)
    );

    // Branch prediction - hum assume karte hain ki branch hamesha liya jayega
    wire is_branch = (instruction[6:0] == 7'b1100011);
    wire [63:0] if_branch_offset = {{51{instruction[31]}}, 
                                instruction[31],
                                instruction[7],
                                instruction[30:25],
                                instruction[11:8],
                                1'b0};
    wire [63:0] if_branch_target = pc_current + if_branch_offset;

    assign branch_predicted = is_branch;
    assign predicted_pc = branch_predicted ? if_branch_target : (pc_current + 4);

    wire nop_instruction;
    assign nop_instruction = (instruction == 32'b0);
    
    // IF/ID Pipeline Register - instruction ko agle stage tak pahunchata hai
    wire [63:0] if_id_pc;
    wire [31:0] if_id_instruction;
    wire if_id_nop_instruction;
    wire if_id_branch_predicted;
    wire [63:0] if_id_predicted_pc;
    
    wire [31:0] instr_to_use = flush ? 32'h00000013 : instruction;  // Agar flush hai to NOP bhejo

    if_id_register if_id(
        .clk(clk),
        .reset(reset | flush),
        .en(~stall | stalled_last_cycle | branch_predicted), 
        .d({
            pc_current, 
            stall & ~stalled_last_cycle ? 32'h00000013 : instr_to_use, // Load hazard ke time NOP dalne ke liye
            stall & ~stalled_last_cycle ? 1'b1 : nop_instruction, 
            branch_predicted, 
            predicted_pc
        }),
        .q({if_id_pc, if_id_instruction, if_id_nop_instruction, if_id_branch_predicted, if_id_predicted_pc})
    );

    // Decode stage - instruction ko samajhne ke liye
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

    // Register File - CPU ke registers
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

    // Load hazard ka pata lagane ke liye - jab load ke turant baad uska data use ho
    wire [4:0] id_ex_rd = id_ex_instruction[11:7];
    // Sirf tab detect karo jab pehle se stall na kiya ho
    wire load_hazard = id_ex_mem_read & 
                     ((id_ex_rd == rs1) | (id_ex_rd == rs2)) &
                     (id_ex_rd != 0) &
                     ~stalled_last_cycle;
    wire stall = load_hazard;

    // Stall tracking - yaad rakhne ke liye ki pichle cycle mein stall kiya tha
    always @(posedge clk or posedge reset) begin
        if (reset)
            stalled_last_cycle <= 1'b0;
        else 
            stalled_last_cycle <= stall;  // Pichle cycle mein stall kiya tha ki nahi
    end

    id_ex_register id_ex(
        .clk(clk),
        .reset(reset | flush),
        .en(~stall | stalled_last_cycle), // Ek stall ke baad hamesha enable karo
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

    // Forwarding Logic - data dependency handle karne ke liye
    wire [4:0] ex_mem_rd = ex_mem_instruction[11:7];
    wire [4:0] mem_wb_rd = mem_wb_instruction[11:7];
    wire [4:0] id_ex_rs1 = id_ex_instruction[19:15];
    wire [4:0] id_ex_rs2 = id_ex_instruction[24:20];
    
    // Super-smart forwarding - load instructions ke liye special handling
    reg [1:0] forwardA, forwardB;
    
    always @(*) begin
        forwardA = 2'b00;  // Default: no forwarding
        
        // EX/MEM stage se forward karo, lekin load ke case mein nahi
        if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1) begin
            // Agar load hai to forward mat karo - data abhi ready nahi hai
            if (!ex_mem_mem_to_reg)
                forwardA = 2'b10;
        end
        
        // MEM/WB se forward karo (load results bhi isme shamil hain)
        if (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs1) begin
            // Load ke baad EX/MEM forwarding ko override karo
            forwardA = 2'b01;
        end
    end

    always @(*) begin
        forwardB = 2'b00;
        
        if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2) begin
            if (!ex_mem_mem_to_reg)
                forwardB = 2'b10;
        end
        
        if (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs2) begin
            forwardB = 2'b01;
        end
    end

    // ALU ke inputs ready karo with forwarding
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

    // Immediate Generation - constants jo instruction mein encode hote hain
    wire [63:0] imm_val;
    
    wire [63:0] i_imm = {{53{id_ex_instruction[31]}}, id_ex_instruction[30:20]};
    wire [63:0] s_imm = {{53{id_ex_instruction[31]}}, id_ex_instruction[30:25], id_ex_instruction[11:7]};
    wire [63:0] b_imm = {{51{id_ex_instruction[31]}}, id_ex_instruction[31], id_ex_instruction[7], 
                         id_ex_instruction[30:25], id_ex_instruction[11:8], 1'b0};
    
    assign imm_val = (id_ex_instruction[6:0] == 7'b0010011 || id_ex_instruction[6:0] == 7'b0000011) ? i_imm :
                     (id_ex_instruction[6:0] == 7'b0100011) ? s_imm :
                     (id_ex_instruction[6:0] == 7'b1100011) ? b_imm : 64'h0;

    wire signed [63:0] alu_in2 = id_ex_alu_src ? imm_val : operandB;

    // ALU - calculations karne ke liye
    wire signed [63:0] alu_result;
    wire zero;
    alu main_alu(
        .instruction(id_ex_instruction),
        .in1(operandA),
        .in2(alu_in2),
        .out(alu_result),
        .zero(zero)
    );

    // Branch ka target calculate karo
    wire [63:0] branch_target = id_ex_pc + b_imm;

    // Branch condition checking - konsa branch lena hai
    wire branch_eq = id_ex_branch & (id_ex_instruction[14:12] == 3'b000);
    wire branch_ne = id_ex_branch & (id_ex_instruction[14:12] == 3'b001);
    wire branch_lt = id_ex_branch & (id_ex_instruction[14:12] == 3'b100);
    wire branch_ge = id_ex_branch & (id_ex_instruction[14:12] == 3'b101);

    // Branch lena hai ya nahi decide karo
    wire branch_taken = (branch_eq & zero) |
                        (branch_ne & ~zero) |
                        (branch_lt & (operandA < operandB)) |
                        (branch_ge & (operandA >= operandB));

    // Agar prediction galat thi to misprediction signal do
    assign branch_mispredicted = id_ex_branch && (branch_taken != id_ex_branch_predicted);
    
    // Prediction galat thi to correct PC ka calculation
    wire [63:0] correct_pc = branch_taken ? branch_target : (id_ex_pc + 4);
    
    // Pipeline flush karo jab prediction galat ho
    assign flush = branch_mispredicted & ~id_ex_branch_predicted;

    // PC ka update: stall, branch misprediction, ya normal increment
    wire [63:0] pc_to_use = stall & ~stalled_last_cycle ? pc_current : 
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

    // Data Memory - RAM jisme data store hota hai
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

    // Write-Back Stage - register mein value wapas likhne ke liye
    assign reg_write_data = mem_wb_mem_to_reg ? mem_wb_mem_read_data : mem_wb_alu_result;
    wire [4:0] mem_wb_rd_fixed = mem_wb_instruction[11:7];
    assign reg_rd = mem_wb_rd_fixed;

    // Program khatam hone ka signal - jab NOP execute ho aur koi branch na ho
    assign end_program = mem_wb_nop_instruction & ~ branch_mispredicted & ~ branch_predicted;

endmodule
