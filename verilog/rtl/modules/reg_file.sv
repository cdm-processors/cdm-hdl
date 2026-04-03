module register_file_m
#(
    parameter XLEN = 16,
    parameter REG_CNT = 8,

    localparam REG_ADDR_W = ($clog2(REG_CNT))
) (
    input logic clk,

    input logic [REG_ADDR_W-1:0] rsi1,
    output logic [XLEN-1:0] rs1,

    input logic [REG_ADDR_W-1:0] rsi2,
    output logic [XLEN-1:0] rs2,

    input logic [REG_ADDR_W-1:0] rdi,
    input logic [XLEN-1:0] rd,

    input logic we
);

  logic [XLEN-1:0] regFile[0:REG_CNT-1];

  function automatic logic [XLEN-1:0] rs(input [REG_ADDR_W-1:0] rsi);
    rs = regFile[rsi];
  endfunction

  always_comb begin
    rs1 = regFile[rsi1];
    rs2 = regFile[rsi2];
  end

  always_ff @(posedge clk) begin : save_rd
    if (we) begin
      regFile[rdi] <= rd;
    end
  end

endmodule  // register_file
