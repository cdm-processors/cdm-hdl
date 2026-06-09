`include "core_base.svh"


module memory
  import core_base_pkg::*;
#(
    parameter INIT_FILE = ""
)
(
    input logic clk,

    // instruction port: always reads a full 16-bit word
    input  data_t instr_addr,
    input  flag_t instr_en,
    output data_t instr,

    // data port: byte or word access, optional sign-extend on read
    input  flag_t data_en,
    input  flag_t data_wr,
    input  flag_t word,         // 1 = word (2 bytes), 0 = byte
    input  flag_t sign_extend,  // 1 = sign-extend byte on read
    input  data_t data_addr,
    input  data_t data_in,
    output data_t data_out
);

  // byte-addressable, little-endian (low byte at lower address)
  // sized for the full 16-bit address space (sim)
  logic [7:0] mem [0:(1 << XLEN) - 1];

  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, mem);
    end
  end

  // instruction read: always a word
  assign instr = instr_en ? {mem[instr_addr + 16'd1], mem[instr_addr]} : '0;

  // data read: word, signed byte or unsigned byte
  data_t rd_word;
  data_t rd_byte;
  assign rd_word = {mem[data_addr + 16'd1], mem[data_addr]};
  assign rd_byte = sign_extend ? {{8{mem[data_addr][7]}}, mem[data_addr]}
                               : {8'b0, mem[data_addr]};
  assign data_out = !data_en ? '0 : (word ? rd_word : rd_byte);

  // data write: byte, or word split into two bytes
  always_ff @(posedge clk) begin
    if (data_en && data_wr) begin
      mem[data_addr] <= data_in[7:0];
      if (word) mem[data_addr + 16'd1] <= data_in[15:8];
    end
  end

endmodule
