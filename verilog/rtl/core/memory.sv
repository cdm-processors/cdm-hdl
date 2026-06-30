`include "core_base.svh"


module memory
  import core_base_pkg::*;
#(
    parameter INIT_FILE = ""
)
(
    input logic clk,

    // instruction port: reads a full 16-bit word (registered)
    input  data_t instr_addr,
    input  flag_t instr_en,
    output data_t instr,

    // data port: byte/word access, optional sign-extend on read (registered)
    input  flag_t data_en,
    input  flag_t data_wr,
    input  flag_t word,
    input  flag_t sign_extend,
    input  data_t data_addr,
    input  data_t data_in,
    output data_t data_out
);

  // Two byte-wide banks so any alignment works and each bank infers a BRAM:
  //   bank0 = bytes at EVEN addresses (byte 2k -> bank0[k])
  //   bank1 = bytes at ODD  addresses (byte 2k+1 -> bank1[k])
  // A word at byte address A spans byte[A] (low) and byte[A+1] (high),
  // which may live in two different bank indices when A is odd.
  localparam int AW = XLEN - 1;                 // 15-bit word/bank index
  logic [7:0] bank0 [0:(1 << AW) - 1];
  logic [7:0] bank1 [0:(1 << AW) - 1];

  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, bank0);              // optional; tests load banks directly
    end
  end

  // ---- data-port addressing ----
  wire              a_lsb = data_addr[0];
  wire [AW-1:0]     dk    = data_addr[XLEN-1:1];          // A >> 1
  wire [AW-1:0]     idx1  = dk;                           // bank1 holds byte A   when A odd
  wire [AW-1:0]     idx0  = dk + (a_lsb ? 1'b1 : 1'b0);   // bank0 holds byte A+1 when A odd

  // write enables: word writes both banks; byte write hits the bank for its parity
  wire we_word  = data_en && data_wr && word;
  wire we_byte  = data_en && data_wr && !word;
  wire bank0_we = we_word || (we_byte && !a_lsb);
  wire bank1_we = we_word || (we_byte &&  a_lsb);
  // byte A goes to the low side, byte A+1 to the high side
  wire [7:0] bank0_wd = (word &&  a_lsb) ? data_in[15:8] : data_in[7:0];
  wire [7:0] bank1_wd = (word && !a_lsb) ? data_in[15:8] : data_in[7:0];

  // ---- instruction-port addressing (PC is always even -> aligned) ----
  wire [AW-1:0] ik = instr_addr[XLEN-1:1];

  // ---- registered reads (this is what makes it BRAM) ----
  logic [7:0] bank0_dq, bank1_dq;   // data-port reads
  logic [7:0] bank0_iq, bank1_iq;   // instruction-port reads
  logic       a_lsb_q;
  flag_t      word_q, sx_q, den_q;

  // bank0: port A = data (read/write), port B = instruction read
  always_ff @(posedge clk) begin
    if (bank0_we) bank0[idx0] <= bank0_wd;
    bank0_dq <= bank0[idx0];
    bank0_iq <= bank0[ik];
  end

  // bank1: port A = data (read/write), port B = instruction read
  always_ff @(posedge clk) begin
    if (bank1_we) bank1[idx1] <= bank1_wd;
    bank1_dq <= bank1[idx1];
    bank1_iq <= bank1[ik];
  end

  always_ff @(posedge clk) begin
    a_lsb_q <= a_lsb;
    word_q  <= word;
    sx_q    <= sign_extend;
    den_q   <= data_en;
  end

  // reassemble bytes: low = byte[A], high = byte[A+1]
  wire [7:0] lo_byte = a_lsb_q ? bank1_dq : bank0_dq;
  wire [7:0] hi_byte = a_lsb_q ? bank0_dq : bank1_dq;

  always_comb begin
    if (!den_q)      data_out = '0;
    else if (word_q) data_out = {hi_byte, lo_byte};
    else if (sx_q)   data_out = {{8{lo_byte[7]}}, lo_byte};
    else             data_out = {8'b0, lo_byte};
  end

  // instruction word: aligned -> low = bank0[ik], high = bank1[ik]
  assign instr = {bank1_iq, bank0_iq};

endmodule
