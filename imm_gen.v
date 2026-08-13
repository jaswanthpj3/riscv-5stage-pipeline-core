// imm_gen.v - Parameterized RISC-V Immediate Generator
module imm_gen #(
    parameter DATA_WIDTH = 32
)(
    input  wire [DATA_WIDTH-1:0] instr,
    output reg  [DATA_WIDTH-1:0] imm_ext
);

    // Opcode definitions for decoding immediate format
    localparam OPCODE_I_TYPE1 = 7'b0010011; // OP-IMM (addi, etc.)
    localparam OPCODE_I_TYPE2 = 7'b0000011; // LOAD (lw, etc.)
    localparam OPCODE_I_TYPE3 = 7'b1100111; // JALR
    localparam OPCODE_S_TYPE  = 7'b0100011; // STORE (sw, etc.)
    localparam OPCODE_B_TYPE  = 7'b1100011; // BRANCH (beq, etc.)
    localparam OPCODE_U_TYPE1 = 7'b0110111; // LUI
    localparam OPCODE_U_TYPE2 = 7'b0010111; // AUIPC
    localparam OPCODE_J_TYPE  = 7'b1101111; // JAL

    wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (opcode)
            OPCODE_I_TYPE1,
            OPCODE_I_TYPE2,
            OPCODE_I_TYPE3: begin
                // Sign-extend 12-bit immediate
                imm_ext = {{20{instr[31]}}, instr[31:20]};
            end

            OPCODE_S_TYPE: begin
                // Store immediate
                imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            OPCODE_B_TYPE: begin
                // Branch immediate (byte-aligned, LSB is 0)
                imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            OPCODE_U_TYPE1,
            OPCODE_U_TYPE2: begin
                // Upper immediate (shift left by 12)
                imm_ext = {instr[31:12], 12'b0};
            end

            OPCODE_J_TYPE: begin
                // Jump immediate (byte-aligned, LSB is 0)
                imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            default: begin
                imm_ext = {DATA_WIDTH{1'b0}};
            end
        endcase
    end

endmodule
