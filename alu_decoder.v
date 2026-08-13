// alu_decoder.v - Translates alu_op + funct fields into 4-bit ALU control
module alu_decoder (
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire       funct7_5, // instr[30]
    output reg  [3:0] alu_control
);

    always @(*) begin
        case (alu_op)
            2'b00: alu_control = 4'b0000; // Force ADD (load/store)
            2'b01: alu_control = 4'b0001; // Force SUB (branch)
            2'b10: begin                  // R-type or I-type decoding
                case (funct3)
                    3'b000: alu_control = (funct7_5) ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: alu_control = 4'b0101; // SLL
                    3'b010: alu_control = 4'b1000; // SLT
                    3'b011: alu_control = 4'b1001; // SLTU
                    3'b100: alu_control = 4'b0100; // XOR
                    3'b101: alu_control = (funct7_5) ? 4'b0111 : 4'b0110; // SRA : SRL
                    3'b110: alu_control = 4'b0011; // OR
                    3'b111: alu_control = 4'b0010; // AND
                    default: alu_control = 4'b0000;
                endcase
            end
            default: alu_control = 4'b0000;
        endcase
    end

endmodule
