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

  //individual clk for load, store data in mem.
  logic rev_clk;
  assign rev_clk = ~clk;

  rams_tdp_rf_rf #(
      .WIDTH (XLEN),
      .ADDR_W(MEM_ADDR_WIDTH)
  ) u_rams_tdp_rf_rf (

      // _____INSTRUCTIONS_____
      .clka(clk),

      .ena(ena),
      .wea(0),

      .addra(next_pc[MEM_ADDR_WIDTH-1:0]),
      .dia  (0),
      .doa  (instr),

      // ______DATA______
      .clkb(rev_clk),

      .enb(enb),
      .web(web),

      .addrb(addrb),
      .dib  (dib),
      .dob  (dob)
  );


endmodule  //core
