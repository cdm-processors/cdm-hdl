module core include core_base_pkg::* (
    input clk;
);

//for load, store data in mem.
logic rev_clk = ~clk;

logic [XLEN-1:0] instr;
logic [XLEN-1:0] next_pc;

ucode_word_t uword;

// ===================== MEMORY ======================
rams_tdp_rf_rf #(
    .WIDTH     (XLEN),
    .ADDR_W    (MEM_ADDR_WIDTH)
) u_rams_tdp_rf_rf (
// _____INSTRUCTIONS_____
    .clka      (clk),

    .ena       (ena),
    .wea       (0),

    .addra     (next_pc[MEM_ADDR_WIDTH-1:0]),
    .dia       (0),
    .doa       (instr),

// ______DATA______
    .clkb      (rev_clk),

    .enb       (enb),
    .web       (web),

    .addrb     (addrb),
    .dib       (dib),
    .dob       (dob)
);



endmodule