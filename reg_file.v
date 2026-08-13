// reg_file.v - Parameterized 32-Register RISC-V Register File
module reg_file #(
    parameter DATA_WIDTH     = 32,
    parameter REG_ADDR_WIDTH = 5   // 2^5 = 32 registers
)(
    input  wire                     clk,
    input  wire                     reset,
    
    // Write Port
    input  wire                     reg_write,
    input  wire [REG_ADDR_WIDTH-1:0] rd_addr,
    input  wire [DATA_WIDTH-1:0]     rd_data,
    
    // Read Ports
    input  wire [REG_ADDR_WIDTH-1:0] rs1_addr,
    output wire [DATA_WIDTH-1:0]     rs1_data,
    input  wire [REG_ADDR_WIDTH-1:0] rs2_addr,
    output wire [DATA_WIDTH-1:0]     rs2_data
);

    localparam NUM_REGS = 1 << REG_ADDR_WIDTH;

    // 32 registers of DATA_WIDTH size
    reg [DATA_WIDTH-1:0] registers [0:NUM_REGS-1];
    integer i;

    // Synchronous Write Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NUM_REGS; i = i + 1) begin
                registers[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (reg_write && (rd_addr != {REG_ADDR_WIDTH{1'b0}})) begin
            // Write data only if reg_write is active and target register is NOT x0
            registers[rd_addr] <= rd_data;
        end
    end

    // Asynchronous Read Logic (x0 hardwired to 0)
    assign rs1_data = (rs1_addr == {REG_ADDR_WIDTH{1'b0}}) ? {DATA_WIDTH{1'b0}} : registers[rs1_addr];
    assign rs2_data = (rs2_addr == {REG_ADDR_WIDTH{1'b0}}) ? {DATA_WIDTH{1'b0}} : registers[rs2_addr];

endmodule

