`timescale 1ns / 1ps
`include "core_base.svh"
module gen_ucode import core_base_pkg::*; (
    input u_addr_t addr,
    output ucode_word_t S
);
endmodule