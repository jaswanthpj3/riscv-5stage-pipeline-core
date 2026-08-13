// tb_alu.v - Testbench for ALU
`timescale 1ns/1ps

module tb_alu;

    parameter DATA_WIDTH     = 32;
    parameter ALU_CTRL_WIDTH = 4;

    reg  [DATA_WIDTH-1:0]     a, b;
    reg  [ALU_CTRL_WIDTH-1:0] alu_control;
    wire [DATA_WIDTH-1:0]     result;
    wire                      zero;

    alu #(
        .DATA_WIDTH(DATA_WIDTH),
        .ALU_CTRL_WIDTH(ALU_CTRL_WIDTH)
    ) uut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("sim/alu_wave.vcd");
        $dumpvars(0, tb_alu);

        // ADD: 15 + 10 = 25
        a = 32'd15; b = 32'd10; alu_control = 4'b0000; #10;
        $display("ADD:  %d + %d = %d (Zero: %b)", a, b, result, zero);

        // SUB: 15 - 15 = 0 (Zero flag trigger)
        a = 32'd15; b = 32'd15; alu_control = 4'b0001; #10;
        $display("SUB:  %d - %d = %d (Zero: %b)", a, b, result, zero);

        // AND: 0xF0F0 & 0xFF00 = 0xF000
        a = 32'hF0F0_F0F0; b = 32'hFFFF_0000; alu_control = 4'b0010; #10;
        $display("AND:  %h & %h = %h", a, b, result);

        // SRA: Signed shift right -16 by 2 = -4
        a = -32'sd16; b = 32'd2; alu_control = 4'b0111; #10;
        $display("SRA:  %d >>> %d = %d", $signed(a), b, $signed(result));

        // SLT: -10 < 5 = 1
        a = -32'sd10; b = 32'sd5; alu_control = 4'b1000; #10;
        $display("SLT:  %d < %d = %d", $signed(a), $signed(b), result);

        $finish;
    end

endmodule
