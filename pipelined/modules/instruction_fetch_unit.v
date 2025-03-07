`timescale 1ns/1ps

module instruction_fetch_unit(
    input clk,
    input reset,
    input branch_taken,
    input [31:0] branch_target,
    input stall_fetch,
    output reg [31:0] current_pc,
    output [31:0] next_pc_plus4
);

    wire [31:0] next_pc;

    // we take the branch target if the branch is taken, otherwise we increment the PC by 4
    assign next_pc = branch_taken ? branch_target : (current_pc + 4);

    // flip flop because it's needed 
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_pc <= 32'b0;
        else if (!stall_fetch)
            current_pc <= next_pc;
    end

    assign next_pc_plus4 = current_pc + 4;

endmodule