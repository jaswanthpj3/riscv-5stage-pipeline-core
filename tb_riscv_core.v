// tb_riscv_core.v - Top-level Core Testbench
`timescale 1ns/1ps

module tb_riscv_core;

    reg clk;
    reg reset;

    // Instantiate Core
    riscv_core #(
        .DATA_WIDTH(32),
        .REG_ADDR_WIDTH(5),
        .MEM_ADDR_WIDTH(10)
    ) uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock Generation (100 MHz -> 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/riscv_core_wave.vcd");
        $dumpvars(0, tb_riscv_core);

        clk = 0;
        reset = 1;

        #12;
        reset = 0; // Release reset

        // Run simulation for 200ns
        #200;

        $display("-------------------------------------------");
        $display("Core Simulation Finished!");
        $display("-------------------------------------------");
        $finish;
    end

endmodule
