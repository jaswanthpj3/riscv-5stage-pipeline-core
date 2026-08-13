// tb_imm_gen.v - Testbench for Immediate Generator
`timescale 1ns/1ps

module tb_imm_gen;

    parameter DATA_WIDTH = 32;

    reg  [DATA_WIDTH-1:0] instr;
    wire [DATA_WIDTH-1:0] imm_ext;

    imm_gen #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .instr(instr),
        .imm_ext(imm_ext)
    );

    initial begin
        $dumpfile("sim/imm_gen_wave.vcd");
        $dumpvars(0, tb_imm_gen);

        // Test 1: I-type ADDI x1, x0, -5 -> Imm = -5 (0xFFFFFFFB)
        // Hex: 0xFFB00093
        instr = 32'hFFB00093; #10;
        $display("I-type Instr: %h | Ext Imm: %h (%d)", instr, imm_ext, $signed(imm_ext));

        // Test 2: S-type SW x2, 8(x1) -> Imm = +8
        // Hex: 0x0020A423
        instr = 32'h0020A423; #10;
        $display("S-type Instr: %h | Ext Imm: %h (%d)", instr, imm_ext, $signed(imm_ext));

        // Test 3: U-type LUI x1, 0x12345 -> Imm = 0x12345000
        // Hex: 0x123450B7
        instr = 32'h123450B7; #10;
        $display("U-type Instr: %h | Ext Imm: %h", instr, imm_ext);

        $finish;
    end

endmodule
