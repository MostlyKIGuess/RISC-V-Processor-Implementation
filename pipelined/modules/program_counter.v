module program_counter(
    input clk,
    input reset,
    input enable,
    input [63:0] next_pc,
    output reg [63:0] pc
);

    initial begin
        pc = 64'b0;
    end

    always @(posedge clk) begin
        if (enable)
            pc <= next_pc;
    end
endmodule
