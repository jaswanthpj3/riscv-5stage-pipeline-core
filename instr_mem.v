// instr_mem.v - Parameterized Instruction Memory
module instr_mem #(
    parameter ADDR_WIDTH = 10,                 // 2^10 = 1024 words (4 KB)
    parameter DATA_WIDTH = 32,                 // RISC-V instructions are 32 bits
    parameter INIT_FILE  = "instructions.hex"  // Path to machine code program file
)(
    input  wire [DATA_WIDTH-1:0] addr,
    output wire [DATA_WIDTH-1:0] instr
);

    // Calculate memory depth (number of words)
    localparam DEPTH = 1 << ADDR_WIDTH;

    // Memory array: DEPTH entries, each DATA_WIDTH wide
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Initialize memory contents from hex file
integer k;
    initial begin
        // Pre-fill entire memory with NOPs (0x00000013)
        for (k = 0; k < DEPTH; k = k + 1) begin
            mem[k] = 32'h0000_0013;
        end
        // Load machine code from file (overwrites first few NOPs)
        $readmemh(INIT_FILE, mem);
    end
    // Word address calculation: Ignore bottom 2 bits for 4-byte alignment
    // Uses address bits [ADDR_WIDTH+1 : 2] to select the line
    wire [ADDR_WIDTH-1:0] word_addr = addr[ADDR_WIDTH+1:2];

    // Asynchronous read for Instruction Fetch
    assign instr = mem[word_addr];

endmodule
