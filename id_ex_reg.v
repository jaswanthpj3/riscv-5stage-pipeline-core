// id_ex_reg.v - Instruction Decode / Execute Register
module id_ex_reg #(
    parameter DATA_WIDTH     = 32,
    parameter REG_ADDR_WIDTH = 5
)(
    input  wire                      clk,
    input  wire                      reset,
    input  wire                      flush,
    
    // Inputs from ID Stage
    input  wire [DATA_WIDTH-1:0]     id_pc,
    input  wire [DATA_WIDTH-1:0]     id_rs1_data,
    input  wire [DATA_WIDTH-1:0]     id_rs2_data,
    input  wire [DATA_WIDTH-1:0]     id_imm_ext,
    input  wire [REG_ADDR_WIDTH-1:0] id_rs1_addr,
    input  wire [REG_ADDR_WIDTH-1:0] id_rs2_addr,
    input  wire [REG_ADDR_WIDTH-1:0] id_rd_addr,
    input  wire                      id_reg_write,
    input  wire                      id_alu_src,
    input  wire                      id_mem_read,
    input  wire                      id_mem_write,
    input  wire                      id_mem_to_reg,
    input  wire                      id_branch,
    input  wire                      id_jump,
    input  wire [3:0]                id_alu_control,

    // Outputs to EX Stage
    output reg  [DATA_WIDTH-1:0]     ex_pc,
    output reg  [DATA_WIDTH-1:0]     ex_rs1_data,
    output reg  [DATA_WIDTH-1:0]     ex_rs2_data,
    output reg  [DATA_WIDTH-1:0]     ex_imm_ext,
    output reg  [REG_ADDR_WIDTH-1:0] ex_rs1_addr,
    output reg  [REG_ADDR_WIDTH-1:0] ex_rs2_addr,
    output reg  [REG_ADDR_WIDTH-1:0] ex_rd_addr,
    output reg                       ex_reg_write,
    output reg                       ex_alu_src,
    output reg                       ex_mem_read,
    output reg                       ex_mem_write,
    output reg                       ex_mem_to_reg,
    output reg                       ex_branch,
    output reg                       ex_jump,
    output reg  [3:0]                ex_alu_control
);

    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            ex_pc          <= {DATA_WIDTH{1'b0}};
            ex_rs1_data    <= {DATA_WIDTH{1'b0}};
            ex_rs2_data    <= {DATA_WIDTH{1'b0}};
            ex_imm_ext     <= {DATA_WIDTH{1'b0}};
            ex_rs1_addr    <= {REG_ADDR_WIDTH{1'b0}};
            ex_rs2_addr    <= {REG_ADDR_WIDTH{1'b0}};
            ex_rd_addr     <= {REG_ADDR_WIDTH{1'b0}};
            ex_reg_write   <= 1'b0;
            ex_alu_src     <= 1'b0;
            ex_mem_read    <= 1'b0;
            ex_mem_write   <= 1'b0;
            ex_mem_to_reg  <= 1'b0;
            ex_branch      <= 1'b0;
            ex_jump        <= 1'b0;
            ex_alu_control <= 4'b0000;
        end else begin
            ex_pc          <= id_pc;
            ex_rs1_data    <= id_rs1_data;
            ex_rs2_data    <= id_rs2_data;
            ex_imm_ext     <= id_imm_ext;
            ex_rs1_addr    <= id_rs1_addr;
            ex_rs2_addr    <= id_rs2_addr;
            ex_rd_addr     <= id_rd_addr;
            ex_reg_write   <= id_reg_write;
            ex_alu_src     <= id_alu_src;
            ex_mem_read    <= id_mem_read;
            ex_mem_write   <= id_mem_write;
            ex_mem_to_reg  <= id_mem_to_reg;
            ex_branch      <= id_branch;
            ex_jump        <= id_jump;
            ex_alu_control <= id_alu_control;
        end
    end

endmodule
