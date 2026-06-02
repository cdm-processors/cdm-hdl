`include "core_base.svh"

module core
  import core_base_pkg::*;
(
    input logic clk,
    input logic rst
);

  logic [XLEN-1:0] instr;
  logic [XLEN-1:0] next_pc;

  ucode_word_t uword;

  pc_file #(
      .XLEN    (core_base_pkg::XLEN),
      .RESET_PC(core_base_pkg::RESET_PC),
      .STEP    (core_base_pkg::PC_STEP)
  ) u_pc_file (
      .i_clk(i_clk),
      .i_rst(i_rst),

      .i_hold     (i_hold),
      .i_inc      (i_inc),
      .i_load     (i_load),
      .i_load_data(i_load_data),

      .o_pc       (o_pc),
      .o_pc_next  (o_pc_next),
      .o_unaligned(o_unaligned)
  );

  // ===================== MEMORY ======================
  //instance of memory
 


endmodule  // core
