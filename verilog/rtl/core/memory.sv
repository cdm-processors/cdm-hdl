`include "core_base.svh"


module memory
  import core_base_pkg::*;
(
    input logic clk,

    input  data_t instr_addr,
    input  flag_t instr_en,
    output data_t instr,

    input  flag_t data_en,
    input  flag_t data_wr,
    input  data_t data_addr,
    input  data_t data_in,
    output data_t data_out
);

  data_t ram[0:(1 << MEM_ADDR_WIDTH)-1];

  logic [MEM_ADDR_WIDTH-1:0] instr_word_addr;
  logic [MEM_ADDR_WIDTH-1:0] data_word_addr;

  assign instr_word_addr = instr_addr[MEM_ADDR_WIDTH:1];
  assign data_word_addr  = data_addr[MEM_ADDR_WIDTH:1];

  assign instr    = instr_en ? ram[instr_word_addr] : '0;
  assign data_out = data_en ? ram[data_word_addr] : '0;

  always_ff @(posedge clk) begin
    if (data_en && data_wr) begin
      ram[data_word_addr] <= data_in;
    end
  end

endmodule
