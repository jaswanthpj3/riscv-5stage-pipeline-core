// if_id_reg.v - Instruction Fetch / Instruction Decode Register
module if_id_reg #(
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire                  flush,
    input  wire                  stall,
    input  wire [DATA_WIDTH-1:0] if_pc,
    input  wire [DATA_WIDTH-1:0] if_instr,
    output reg  [DATA_WIDTH-1:0] id_pc,
    output reg  [DATA_WIDTH-1:0] id_instr
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            id_pc    <= {DATA_WIDTH{1'b0}};
            id_instr <= 32'h0000_0013; // NOP (addi x0, x0, 0)
        end else if (!stall) begin
            id_pc    <= if_pc;
            id_instr <= if_instr;
        end
    end

endmodule
