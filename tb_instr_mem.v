// tb_instr_mem.v - Testbench for Instruction Memory
`timescale 1ns/1ps

module tb_instr_mem;

    parameter ADDR_WIDTH = 10;
    parameter DATA_WIDTH = 32;

    reg  [DATA_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] instr;

    // Instantiate Instruction Memory
    instr_mem #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .INIT_FILE("sim/instructions.hex")
    ) uut (
        .addr(addr),
        .instr(instr)
    );

    initial begin
        $dumpfile("sim/instr_mem_wave.vcd");
        $dumpvars(0, tb_instr_mem);

        // Test fetching sequence of byte addresses (0x0, 0x4, 0x8, 0xC)
        addr = 32'h0000_0000; #10;
        $display("Addr: 0x%h | Instr: 0x%h", addr, instr);

        addr = 32'h0000_0004; #10;
        $display("Addr: 0x%h | Instr: 0x%h", addr, instr);

        addr = 32'h0000_0008; #10;
        $display("Addr: 0x%h | Instr: 0x%h", addr, instr);

        addr = 32'h0000_000C; #10;
        $display("Addr: 0x%h | Instr: 0x%h", addr, instr);

        $finish;
    end

endmodule

