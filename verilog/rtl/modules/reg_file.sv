`timescale 1ns / 1ps

`include "core_base.svh"

module reg_file_m import core_base_pkg::*;
(
    input logic clk,
    input logic we,

    input reg_addr_t rsi0,
    output reg_t rs0,

    input reg_addr_t rsi1,
    output reg_t rs1,

    input reg_addr_t rdi,
    input reg_t rd_in,
    output reg_t rd_out,

    output reg_t fp
);

  reg_t regFile[0:REG_CNT-1];

  always_comb begin
    rs0 = regFile[rsi0];
    rs1 = regFile[rsi1];
    rd_out = regFile[rdi];
    fp = regFile[3'd7];
  end

  always_ff @(posedge clk) begin : save_rd
    if (we) begin
      regFile[rdi] <= rd_in;
    end
  end

endmodule  // register_file
