`timescale 1ns / 1ps

`include "core_base.svh"

module reg_file_m import core_base_pkg::*;
(
    input logic clk,
    input logic we,

    input reg_addr_t rsi1,
    output reg_t rs1,

    input reg_addr_t rsi2,
    output reg_t rs2,

    input reg_addr_t rdi,
    input reg_t rd
);

  logic [XLEN-1:0] regFile[0:REG_CNT-1];

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
