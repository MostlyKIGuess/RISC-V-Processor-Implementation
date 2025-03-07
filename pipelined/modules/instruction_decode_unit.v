`timescale 1ns / 1ps

module instruction_decode_unit(
    input clk,
    input reset,
    input [31:0] pc_plus4_fetch,  // PCplus4F: PC + 4 from fetch 
    input [31:0] pc_fetch,        
    input [31:0] instruction_fetch, 
    input flush_decode,           // flushD: Flush signal for decode stage
    input stall_decode,           // stallD: Stall signal for decode stage
    input [1:0] imm_src_decode,   // ImmSrcD: Immediate source for decode stage
    input reg_write_enable_writeback, // RegWriteW: Register write enable from writeback stage
    input [31:0] write_data_writeback, // ResultW: Write data from writeback stage
    input [4:0] write_register_writeback, // RdW: Write register from writeback stage

    output reg [31:0] instruction_decode, // these are all for decode stage
    output reg [31:0] pc_plus4_decode,    
    output reg [31:0] immediate_extended_decode, 
    output reg [31:0] pc_decode,          // PCD: decode stage PC
    output reg [31:0] read_data1_decode, // read data 
    output reg [31:0] read_data2_decode  // read data 
);

    // decode's pc is getting set here
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_plus4_decode <= 32'b0;
        else if (!stall_decode)
            pc_plus4_decode <= pc_plus4_fetch;
    end

    // if need to flush
    always @(posedge clk or posedge reset) begin
        if (reset)
            instruction_decode <= 32'b0;
        else if (flush_decode)
            instruction_decode <= 32'b0;
        else if (!stall_decode)
            instruction_decode <= instruction_fetch;
    end

    // pc for decode is flushing before instruction wass getting
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_decode <= 32'b0;
        else if (flush_decode)
            pc_decode <= 32'b0;
        else if (!stall_decode)
            pc_decode <= pc_fetch;
    end

    reg [31:0] register_file [0:31]; 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            integer i;
            for (i = 0; i < 32; i = i + 1)
                register_file[i] <= 32'b0;
        end else if (reg_write_enable_writeback) begin
            register_file[write_register_writeback] <= write_data_writeback;
        end
    end
    // this happens anywhere on clock
    always @(*) begin
        read_data1_decode = register_file[instruction_decode[19:15]];
        read_data2_decode = register_file[instruction_decode[24:20]];
    end

    // the ">>" LMFAO
    always @(*) begin
        case (imm_src_decode)
            2'b00: immediate_extended_decode = {{20{instruction_decode[31]}}, instruction_decode[31:20]}; // I-type
            2'b01: immediate_extended_decode = {{20{instruction_decode[31]}}, instruction_decode[31:25], instruction_decode[11:7]}; // S-type
            2'b10: immediate_extended_decode = {{19{instruction_decode[31]}}, instruction_decode[31], instruction_decode[7], instruction_decode[30:25], instruction_decode[11:8], 1'b0}; // B-type
            default: immediate_extended_decode = 32'b0;
        endcase
    end

endmodule