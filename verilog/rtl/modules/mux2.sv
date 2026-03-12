`timescale 1ns / 1ps
import core_base_pkg::*;

module mux2 #(
  parameter int W = XLEN
)(
  input  logic [W-1:0] d0, d1,
  input  logic sel,
  output logic [W-1:0] y
);
  always_comb begin
    y = sel ? d1 : d0;
  end
endmodule