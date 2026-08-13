// tb_pc.v - Testbench for Parameterized PC
`timescale 1ns/1ps

module tb_pc;

    // Local testbench parameters
    parameter TEST_WIDTH = 32;
    parameter TEST_RESET = 32'h0000_0000;

    reg                     clk;
    reg                     reset;
    reg  [TEST_WIDTH-1:0]   next_pc;
    wire [TEST_WIDTH-1:0]   current_pc;

    // Instantiate PC unit with parameters
    pc #(
        .PC_WIDTH(TEST_WIDTH),
        .RESET_ADDR(TEST_RESET)
    ) uut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .current_pc(current_pc)
    );

    // Clock Generation (100MHz -> 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Dump waveform for GTKWave
        $dumpfile("sim/pc_wave.vcd");
        $dumpvars(0, tb_pc);

        // Initialize signals
        clk = 0;
        reset = 1;
        next_pc = TEST_RESET;

        #12;
        reset = 0; // Release reset

        // Advance PC in steps of 4
        #10 next_pc = current_pc + 32'd4;
        #10 next_pc = current_pc + 32'd4;
        #10 next_pc = current_pc + 32'd4;
        #10 next_pc = current_pc + 32'd4;

        #20;
        $display("Parameterized PC Test Complete!");
        $finish;
    end

endmodule
