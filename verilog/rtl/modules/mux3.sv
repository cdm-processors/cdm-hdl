`timescale 1ns / 1ps
import core_base_pkg::*;

module mux3 #(
  parameter int W = XLEN
)(
  input  logic [W-1:0] d0, d1, d2,
  input  logic [1:0] sel,
  output logic [W-1:0] y
);
  always_comb begin
    unique case(sel)
      2'd0: y = d0;
      2'd1: y = d1;
      2'd2: y = d2;
      default: y = d0;
    endcase
  end
endmodule