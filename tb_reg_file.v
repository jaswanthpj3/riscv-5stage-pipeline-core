// tb_reg_file.v - Testbench for Register File
`timescale 1ns/1ps

module tb_reg_file;

    parameter DATA_WIDTH     = 32;
    parameter REG_ADDR_WIDTH = 5;

    reg                      clk;
    reg                      reset;
    reg                      reg_write;
    reg  [REG_ADDR_WIDTH-1:0] rd_addr;
    reg  [DATA_WIDTH-1:0]     rd_data;
    reg  [REG_ADDR_WIDTH-1:0] rs1_addr;
    wire [DATA_WIDTH-1:0]     rs1_data;
    reg  [REG_ADDR_WIDTH-1:0] rs2_addr;
    wire [DATA_WIDTH-1:0]     rs2_data;

    // Instantiate Register File
    reg_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rs1_addr(rs1_addr),
        .rs1_data(rs1_data),
        .rs2_addr(rs2_addr),
        .rs2_data(rs2_data)
    );

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/reg_file_wave.vcd");
        $dumpvars(0, tb_reg_file);

        clk = 0;
        reset = 1;
        reg_write = 0;
        rd_addr = 0;
        rd_data = 0;
        rs1_addr = 0;
        rs2_addr = 0;

        #12;
        reset = 0; // Release reset

        // Test 1: Write 0xABCD1234 into x1
        #10;
        reg_write = 1;
        rd_addr   = 5'd1;
        rd_data   = 32'hABCD_1234;

        // Test 2: Write 0x5555AAAA into x2
        #10;
        rd_addr   = 5'd2;
        rd_data   = 32'h5555_AAAA;

        // Test 3: Attempt to write 0xFFFFFFFF into x0 (should stay 0)
        #10;
        rd_addr   = 5'd0;
        rd_data   = 32'hFFFF_FFFF;

        // Test 4: Disable write and read x1 and x2
        #10;
        reg_write = 0;
        rs1_addr  = 5'd1;
        rs2_addr  = 5'd2;

        #5;
        $display("Read x1 (expected ABCD1234): 0x%h", rs1_data);
        $display("Read x2 (expected 5555AAAA): 0x%h", rs2_data);

        // Test 5: Read x0 (expected 0)
        #10;
        rs1_addr  = 5'd0;
        #5;
        $display("Read x0 (expected 00000000): 0x%h", rs1_data);

        #10;
        $finish;
    end

endmodule
