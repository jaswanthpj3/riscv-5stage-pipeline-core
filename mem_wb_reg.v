// mem_wb_reg.v - Memory / Writeback Register
module mem_wb_reg #(
    parameter DATA_WIDTH     = 32,
    parameter REG_ADDR_WIDTH = 5
)(
    input  wire                      clk,
    input  wire                      reset,
    
    // Inputs from MEM Stage
    input  wire [DATA_WIDTH-1:0]     mem_alu_result,
    input  wire [DATA_WIDTH-1:0]     mem_read_data,
    input  wire [REG_ADDR_WIDTH-1:0] mem_rd_addr,
    input  wire                      mem_reg_write,
    input  wire                      mem_mem_to_reg,

    // Outputs to WB Stage
    output reg  [DATA_WIDTH-1:0]     wb_alu_result,
    output reg  [DATA_WIDTH-1:0]     wb_read_data,
    output reg  [REG_ADDR_WIDTH-1:0] wb_rd_addr,
    output reg                       wb_reg_write,
    output reg                       wb_mem_to_reg
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_alu_result <= {DATA_WIDTH{1'b0}};
            wb_read_data  <= {DATA_WIDTH{1'b0}};
            wb_rd_addr    <= {REG_ADDR_WIDTH{1'b0}};
            wb_reg_write  <= 1'b0;
            wb_mem_to_reg <= 1'b0;
        end else begin
            wb_alu_result <= mem_alu_result;
            wb_read_data  <= mem_read_data;
            wb_rd_addr    <= mem_rd_addr;
            wb_reg_write  <= mem_reg_write;
            wb_mem_to_reg <= mem_mem_to_reg;
        end
    end

endmodule

