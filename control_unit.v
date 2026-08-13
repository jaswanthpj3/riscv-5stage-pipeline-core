// control_unit.v - Main Instruction Decoder
module control_unit (
    input  wire [6:0] opcode,
    output reg        reg_write,
    output reg        alu_src,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        branch,
    output reg        jump,
    output reg  [1:0] alu_op
);

    // RISC-V Opcodes
    localparam OPCODE_R_TYPE = 7'b0110011; // add, sub, and, or, slt, etc.
    localparam OPCODE_I_TYPE = 7'b0010011; // addi, andi, ori, etc.
    localparam OPCODE_LOAD   = 7'b0000011; // lw
    localparam OPCODE_STORE  = 7'b0100011; // sw
    localparam OPCODE_BRANCH = 7'b1100011; // beq, bne
    localparam OPCODE_JAL    = 7'b1101111; // jal

    always @(*) begin
        // Default control signal values
        reg_write = 1'b0;
        alu_src   = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        mem_to_reg= 1'b0;
        branch    = 1'b0;
        jump      = 1'b0;
        alu_op    = 2'b00;

        case (opcode)
            OPCODE_R_TYPE: begin
                reg_write = 1'b1;
                alu_op    = 2'b10;
            end

            OPCODE_I_TYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b10;
            end

            OPCODE_LOAD: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_op     = 2'b00; // ADD for address calculation
            end

            OPCODE_STORE: begin
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_op    = 2'b00; // ADD for address calculation
            end

            OPCODE_BRANCH: begin
                branch = 1'b1;
                alu_op = 2'b01; // SUB for comparison
            end

            OPCODE_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
            end

            default: begin
                // Retain default safe values
            end
        endcase
    end

endmodule
