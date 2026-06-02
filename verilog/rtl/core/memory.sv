`include "core_base.svh"


module memory
  import core_base_pkg::*;
(
    input  reg_t  next_pc,
    input  flag_t instr_en,
    output data_t instr,

    input  flag_t data_en,
    input  flag_t data_wr,
    input  data_t data_addr,
    input  data_t data_in,
    output data_t data_out
);

  //individual clk for load/store data in mem.
  logic rev_clk;
  assign rev_clk = ~clk;

  rams_tdp_rf_rf #(
      .WIDTH (XLEN),
      .ADDR_W(MEM_ADDR_WIDTH)
  ) u_rams_tdp_rf_rf (

      // _____INSTRUCTIONS_____
      .clka(clk),

      .ena(instr_en),
      .wea(0),

      .addra(next_pc[MEM_ADDR_WIDTH-1:0]),
      .dia  (0),
      .doa  (instr),

      // ______DATA______
      .clkb(rev_clk),

      .enb(data_en),
      .web(data_wr),

      .addrb(data_addr),
      .dib  (data_in),
      .dob  (data_out)
  );

endmodule
