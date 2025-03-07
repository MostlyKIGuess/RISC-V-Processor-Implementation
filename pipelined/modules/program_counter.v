module program_counter(
    input clk,
    input reset,
    input enable,
    input [63:0] next_pc,
    output reg [63:0] pc
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 64'b0;
        else if (enable)
            pc <= next_pc;
    end
endmodule
