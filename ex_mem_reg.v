// ex_mem_reg.v - Execute / Memory Register
module ex_mem_reg #(
    parameter DATA_WIDTH     = 32,
    parameter REG_ADDR_WIDTH = 5
)(
    input  wire                      clk,
    input  wire                      reset,
    
    // Inputs from EX Stage
    input  wire [DATA_WIDTH-1:0]     ex_branch_target,
    input  wire [DATA_WIDTH-1:0]     ex_alu_result,
    input  wire [DATA_WIDTH-1:0]     ex_rs2_data,
    input  wire [REG_ADDR_WIDTH-1:0] ex_rd_addr,
    input  wire                      ex_zero,
    input  wire                      ex_reg_write,
    input  wire                      ex_mem_read,
    input  wire                      ex_mem_write,
    input  wire                      ex_mem_to_reg,
    input  wire                      ex_branch,
    input  wire                      ex_jump,

    // Outputs to MEM Stage
    output reg  [DATA_WIDTH-1:0]     mem_branch_target,
    output reg  [DATA_WIDTH-1:0]     mem_alu_result,
    output reg  [DATA_WIDTH-1:0]     mem_rs2_data,
    output reg  [REG_ADDR_WIDTH-1:0] mem_rd_addr,
    output reg                       mem_zero,
    output reg                       mem_reg_write,
    output reg                       mem_mem_read,
    output reg                       mem_mem_write,
    output reg                       mem_mem_to_reg,
    output reg                       mem_branch,
    output reg                       mem_jump
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_branch_target <= {DATA_WIDTH{1'b0}};
            mem_alu_result    <= {DATA_WIDTH{1'b0}};
            mem_rs2_data      <= {DATA_WIDTH{1'b0}};
            mem_rd_addr       <= {REG_ADDR_WIDTH{1'b0}};
            mem_zero          <= 1'b0;
            mem_reg_write     <= 1'b0;
            mem_mem_read      <= 1'b0;
            mem_mem_write     <= 1'b0;
            mem_mem_to_reg    <= 1'b0;
            mem_branch        <= 1'b0;
            mem_jump          <= 1'b0;
        end else begin
            mem_branch_target <= ex_branch_target;
            mem_alu_result    <= ex_alu_result;
            mem_rs2_data      <= ex_rs2_data;
            mem_rd_addr       <= ex_rd_addr;
            mem_zero          <= ex_zero;
            mem_reg_write     <= ex_reg_write;
            mem_mem_read      <= ex_mem_read;
            mem_mem_write     <= ex_mem_write;
            mem_mem_to_reg    <= ex_mem_to_reg;
            mem_branch        <= ex_branch;
            mem_jump          <= ex_jump;
        end
    end

endmodule
