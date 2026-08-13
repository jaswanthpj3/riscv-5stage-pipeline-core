module riscv_core (
    input wire clk,
    input wire reset
);

    parameter DATA_WIDTH     = 32;
    parameter REG_ADDR_WIDTH = 5;
    parameter MEM_ADDR_WIDTH = 10;

    // =========================================================================
    // WIRE DECLARATIONS
    // =========================================================================
    
    // Hazard Control Signals
    wire [1:0] forward_a;
    wire [1:0] forward_b;
    wire       stall_pc;
    wire       stall_if_id;
    wire       flush_id_ex;
    wire       flush_if_id;

    // Stage 1: Fetch (IF)
    wire [DATA_WIDTH-1:0] if_pc;
    wire [DATA_WIDTH-1:0] if_next_pc;
    wire [DATA_WIDTH-1:0] if_instr;
    wire                  pcsrc;

    // Stage 2: Decode (ID)
    wire [DATA_WIDTH-1:0] id_pc;
    wire [DATA_WIDTH-1:0] id_instr;
    wire [REG_ADDR_WIDTH-1:0] id_rs1_addr = id_instr[19:15];
    wire [REG_ADDR_WIDTH-1:0] id_rs2_addr = id_instr[24:20];
    wire [REG_ADDR_WIDTH-1:0] id_rd_addr  = id_instr[11:7];
    wire [DATA_WIDTH-1:0] id_rs1_data;
    wire [DATA_WIDTH-1:0] id_rs2_data;
    wire [DATA_WIDTH-1:0] id_imm_ext;
    wire       id_reg_write;
    wire       id_alu_src;
    wire       id_mem_read;
    wire       id_mem_write;
    wire       id_mem_to_reg;
    wire       id_branch;
    wire       id_jump;
    wire [1:0] id_alu_op;
    wire [3:0] id_alu_control;

    // Stage 3: Execute (EX)
    wire [DATA_WIDTH-1:0]     ex_pc;
    wire [DATA_WIDTH-1:0]     ex_rs1_data;
    wire [DATA_WIDTH-1:0]     ex_rs2_data;
    wire [DATA_WIDTH-1:0]     ex_imm_ext;
    wire [REG_ADDR_WIDTH-1:0] ex_rs1_addr;
    wire [REG_ADDR_WIDTH-1:0] ex_rs2_addr;
    wire [REG_ADDR_WIDTH-1:0] ex_rd_addr;
    wire                      ex_reg_write;
    wire                      ex_alu_src;
    wire                      ex_mem_read;
    wire                      ex_mem_write;
    wire                      ex_mem_to_reg;
    wire                      ex_branch;
    wire                      ex_jump;
    wire [3:0]                ex_alu_control;
    
    reg  [DATA_WIDTH-1:0]     alu_operand_a;
    reg  [DATA_WIDTH-1:0]     forwarded_rs2_data;
    wire [DATA_WIDTH-1:0]     alu_operand_b;
    wire [DATA_WIDTH-1:0]     ex_alu_result;
    wire                      ex_zero;
    wire [DATA_WIDTH-1:0]     ex_branch_target;

    // Stage 4: Memory (MEM)
    wire [DATA_WIDTH-1:0]     mem_branch_target;
    wire [DATA_WIDTH-1:0]     mem_alu_result;
    wire [DATA_WIDTH-1:0]     mem_rs2_data;
    wire [REG_ADDR_WIDTH-1:0] mem_rd_addr;
    wire                      mem_zero;
    wire                      mem_reg_write;
    wire                      mem_mem_read;
    wire                      mem_mem_write;
    wire                      mem_mem_to_reg;
    wire                      mem_branch;
    wire                      mem_jump;
    wire [DATA_WIDTH-1:0]     mem_read_data;

    // Stage 5: Writeback (WB)
    wire [DATA_WIDTH-1:0]     wb_alu_result;
    wire [DATA_WIDTH-1:0]     wb_read_data;
    wire [REG_ADDR_WIDTH-1:0] wb_rd_addr;
    wire                      wb_reg_write;
    wire                      wb_mem_to_reg;
    wire [DATA_WIDTH-1:0]     wb_write_data;

    // =========================================================================
    // HAZARD UNIT
    // =========================================================================
    hazard_unit #(
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    ) hazard_unit_inst (
        .id_rs1_addr(id_rs1_addr),
        .id_rs2_addr(id_rs2_addr),
        .ex_rs1_addr(ex_rs1_addr),
        .ex_rs2_addr(ex_rs2_addr),
        .mem_rd_addr(mem_rd_addr),
        .wb_rd_addr(wb_rd_addr),
        .mem_reg_write(mem_reg_write),
        .wb_reg_write(wb_reg_write),
        .ex_mem_read(ex_mem_read),
        .ex_rd_addr(ex_rd_addr),
        .pcsrc(pcsrc),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .stall_pc(stall_pc),
        .stall_if_id(stall_if_id),
        .flush_id_ex(flush_id_ex),
        .flush_if_id(flush_if_id)
    );

    // =========================================================================
    // STAGE 1: FETCH (IF)
    // =========================================================================
    assign if_next_pc = pcsrc ? mem_branch_target : (if_pc + 32'd4);

    pc #(
        .PC_WIDTH(DATA_WIDTH),
        .RESET_ADDR(32'h0000_0000)
    ) pc_inst (
        .clk(clk),
        .reset(reset),
        .next_pc(stall_pc ? if_pc : if_next_pc),
        .current_pc(if_pc)
    );

    instr_mem #(
        .ADDR_WIDTH(MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INIT_FILE("sim/instructions.hex")
    ) imem_inst (
        .addr(if_pc),
        .instr(if_instr)
    );

    if_id_reg #(
        .DATA_WIDTH(DATA_WIDTH)
    ) if_id_inst (
        .clk(clk),
        .reset(reset),
        .flush(flush_if_id),
        .stall(stall_if_id),
        .if_pc(if_pc),
        .if_instr(if_instr),
        .id_pc(id_pc),
        .id_instr(id_instr)
    );

    // =========================================================================
    // STAGE 2: DECODE (ID)
    // =========================================================================
    reg_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    ) reg_file_inst (
        .clk(clk),
        .reset(reset),
        .reg_write(wb_reg_write),
        .rd_addr(wb_rd_addr),
        .rd_data(wb_write_data),
        .rs1_addr(id_rs1_addr),
        .rs1_data(id_rs1_data),
        .rs2_addr(id_rs2_addr),
        .rs2_data(id_rs2_data)
    );

    imm_gen #(
        .DATA_WIDTH(DATA_WIDTH)
    ) imm_gen_inst (
        .instr(id_instr),
        .imm_ext(id_imm_ext)
    );

    control_unit control_unit_inst (
        .opcode(id_instr[6:0]),
        .reg_write(id_reg_write),
        .alu_src(id_alu_src),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .mem_to_reg(id_mem_to_reg),
        .branch(id_branch),
        .jump(id_jump),
        .alu_op(id_alu_op)
    );

    alu_decoder alu_decoder_inst (
        .alu_op(id_alu_op),
        .funct3(id_instr[14:12]),
        .funct7_5(id_instr[30]),
        .alu_control(id_alu_control)
    );

    id_ex_reg #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    ) id_ex_inst (
        .clk(clk),
        .reset(reset),
        .flush(flush_id_ex),
        .id_pc(id_pc),
        .id_rs1_data(id_rs1_data),
        .id_rs2_data(id_rs2_data),
        .id_imm_ext(id_imm_ext),
        .id_rs1_addr(id_rs1_addr),
        .id_rs2_addr(id_rs2_addr),
        .id_rd_addr(id_rd_addr),
        .id_reg_write(id_reg_write),
        .id_alu_src(id_alu_src),
        .id_mem_read(id_mem_read),
        .id_mem_write(id_mem_write),
        .id_mem_to_reg(id_mem_to_reg),
        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_alu_control(id_alu_control),
        .ex_pc(ex_pc),
        .ex_rs1_data(ex_rs1_data),
        .ex_rs2_data(ex_rs2_data),
        .ex_imm_ext(ex_imm_ext),
        .ex_rs1_addr(ex_rs1_addr),
        .ex_rs2_addr(ex_rs2_addr),
        .ex_rd_addr(ex_rd_addr),
        .ex_reg_write(ex_reg_write),
        .ex_alu_src(ex_alu_src),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        .ex_alu_control(ex_alu_control)
    );

    // =========================================================================
    // STAGE 3: EXECUTE (EX)
    // =========================================================================
    always @(*) begin
        case (forward_a)
            2'b10:   alu_operand_a = mem_alu_result;
            2'b01:   alu_operand_a = wb_write_data;
            default: alu_operand_a = ex_rs1_data;
        endcase
    end

    always @(*) begin
        case (forward_b)
            2'b10:   forwarded_rs2_data = mem_alu_result;
            2'b01:   forwarded_rs2_data = wb_write_data;
            default: forwarded_rs2_data = ex_rs2_data;
        endcase
    end

    assign alu_operand_b = ex_alu_src ? ex_imm_ext : forwarded_rs2_data;

    alu #(
        .DATA_WIDTH(DATA_WIDTH),
        .ALU_CTRL_WIDTH(4)
    ) alu_inst (
        .a(alu_operand_a),
        .b(alu_operand_b),
        .alu_control(ex_alu_control),
        .result(ex_alu_result),
        .zero(ex_zero)
    );

    assign ex_branch_target = ex_pc + ex_imm_ext;

    ex_mem_reg #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    ) ex_mem_inst (
        .clk(clk),
        .reset(reset),
        .ex_branch_target(ex_branch_target),
        .ex_alu_result(ex_alu_result),
        .ex_rs2_data(forwarded_rs2_data),
        .ex_rd_addr(ex_rd_addr),
        .ex_zero(ex_zero),
        .ex_reg_write(ex_reg_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        .mem_branch_target(mem_branch_target),
        .mem_alu_result(mem_alu_result),
        .mem_rs2_data(mem_rs2_data),
        .mem_rd_addr(mem_rd_addr),
        .mem_zero(mem_zero),
        .mem_reg_write(mem_reg_write),
        .mem_mem_read(mem_mem_read),
        .mem_mem_write(mem_mem_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_branch(mem_branch),
        .mem_jump(mem_jump)
    );

    // =========================================================================
    // STAGE 4: MEMORY (MEM)
    // =========================================================================
    assign pcsrc = (mem_branch & mem_zero) | mem_jump;

    data_mem #(
        .ADDR_WIDTH(MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dmem_inst (
        .clk(clk),
        .mem_write(mem_mem_write),
        .mem_read(mem_mem_read),
        .addr(mem_alu_result),
        .write_data(mem_rs2_data),
        .read_data(mem_read_data)
    );

    mem_wb_reg #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    ) mem_wb_inst (
        .clk(clk),
        .reset(reset),
        .mem_alu_result(mem_alu_result),
        .mem_read_data(mem_read_data),
        .mem_rd_addr(mem_rd_addr),
        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .wb_alu_result(wb_alu_result),
        .wb_read_data(wb_read_data),
        .wb_rd_addr(wb_rd_addr),
        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg)
    );

    // =========================================================================
    // STAGE 5: WRITEBACK (WB)
    // =========================================================================
    assign wb_write_data = wb_mem_to_reg ? wb_read_data : wb_alu_result;

endmodule