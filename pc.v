// pc.v - Parameterized Program Counter Register
module pc #(
    parameter PC_WIDTH   = 32,
    parameter RESET_ADDR = 32'h0000_0000
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire [PC_WIDTH-1:0]   next_pc,
    output reg  [PC_WIDTH-1:0]   current_pc
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_pc <= RESET_ADDR;
        end else begin
            current_pc <= next_pc;
        end
    end

endmodule
