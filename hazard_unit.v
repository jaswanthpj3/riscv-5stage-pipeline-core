// hazard_unit.v - Handles Data Forwarding, Stalls, and Branch Flushing
module hazard_unit #(
    parameter REG_ADDR_WIDTH = 5
)(
    // Inputs for Forwarding Logic
    input  wire [REG_ADDR_WIDTH-1:0] id_rs1_addr,
    input  wire [REG_ADDR_WIDTH-1:0] id_rs2_addr,
    input  wire [REG_ADDR_WIDTH-1:0] ex_rs1_addr,
    input  wire [REG_ADDR_WIDTH-1:0] ex_rs2_addr,
    input  wire [REG_ADDR_WIDTH-1:0] mem_rd_addr,
    input  wire [REG_ADDR_WIDTH-1:0] wb_rd_addr,
    input  wire                      mem_reg_write,
    input  wire                      wb_reg_write,

    // Inputs for Load-Use Hazard Detection
    input  wire                      ex_mem_read,
    input  wire [REG_ADDR_WIDTH-1:0] ex_rd_addr,

    // Input for Control Hazard (Branch Taken)
    input  wire                      pcsrc,

    // Forwarding MUX Selection Outputs
    // 2'b00: Select Register File Value
    // 2'b10: Forward from EX/MEM stage (ALU Result)
    // 2'b01: Forward from MEM/WB stage (Writeback Data)
    output reg  [1:0]                forward_a,
    output reg  [1:0]                forward_b,

    // Pipeline Control Outputs
    output reg                       stall_pc,
    output reg                       stall_if_id,
    output reg                       flush_id_ex,
    output reg                       flush_if_id
);

    // -------------------------------------------------------------------------
    // 1. DATA FORWARDING LOGIC (Execute Stage ALU Inputs)
    // -------------------------------------------------------------------------
    always @(*) begin
        // Forwarding for Operand A (rs1)
        if (mem_reg_write && (mem_rd_addr != 0) && (mem_rd_addr == ex_rs1_addr)) begin
            forward_a = 2'b10; // Forward from EX/MEM stage
        end else if (wb_reg_write && (wb_rd_addr != 0) && (wb_rd_addr == ex_rs1_addr)) begin
            forward_a = 2'b01; // Forward from MEM/WB stage
        end else begin
            forward_a = 2'b00; // No forwarding
        end

        // Forwarding for Operand B (rs2)
        if (mem_reg_write && (mem_rd_addr != 0) && (mem_rd_addr == ex_rs2_addr)) begin
            forward_b = 2'b10; // Forward from EX/MEM stage
        end else if (wb_reg_write && (wb_rd_addr != 0) && (wb_rd_addr == ex_rs2_addr)) begin
            forward_b = 2'b01; // Forward from MEM/WB stage
        end else begin
            forward_b = 2'b00; // No forwarding
        end
    end

    // -------------------------------------------------------------------------
    // 2. LOAD-USE HAZARD STALLING & BRANCH FLUSHING LOGIC
    // -------------------------------------------------------------------------
    always @(*) begin
        // Default: No stalls or flushes
        stall_pc    = 1'b0;
        stall_if_id = 1'b0;
        flush_id_ex = 1'b0;
        flush_if_id = 1'b0;

        // Load-Use Hazard Detection:
        // If an instruction in EX is a Load (mem_read=1) and its destination register
        // matches rs1 or rs2 of the instruction in Decode, insert 1 stall cycle.
        if (ex_mem_read && (ex_rd_addr != 0) && 
           ((ex_rd_addr == id_rs1_addr) || (ex_rd_addr == id_rs2_addr))) begin
            stall_pc    = 1'b1; // Freeze Program Counter
            stall_if_id = 1'b1; // Freeze IF/ID Register
            flush_id_ex = 1'b1; // Insert NOP into ID/EX Register
        end

        // Control Hazard Detection (Branch or Jump Taken):
        // Flush the instructions in IF/ID and ID/EX that were fetched speculatively.
        if (pcsrc) begin
            flush_if_id = 1'b1;
            flush_id_ex = 1'b1;
        end
    end

endmodule
