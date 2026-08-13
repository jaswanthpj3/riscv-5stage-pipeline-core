// data_mem.v - Parameterized Data Memory
module data_mem #(
    parameter ADDR_WIDTH = 10, // 2^10 = 1024 words (4 KB memory)
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  mem_write,
    input  wire                  mem_read,
    input  wire [DATA_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] write_data,
    output wire [DATA_WIDTH-1:0] read_data
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // Memory array
    reg [DATA_WIDTH-1:0] dmem [0:DEPTH-1];

    // Word address calculation (ignoring bottom 2 bits for byte alignment)
    wire [ADDR_WIDTH-1:0] word_addr = addr[ADDR_WIDTH+1:2];

    // Synchronous Write Logic
    always @(posedge clk) begin
        if (mem_write) begin
            dmem[word_addr] <= write_data;
        end
    end

    // Asynchronous Read Logic
    assign read_data = (mem_read) ? dmem[word_addr] : {DATA_WIDTH{1'b0}};

endmodule

