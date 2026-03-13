package core_base_pkg;

    localparam int XLEN = 16;
    localparam int REGISTER_COUNT = 8;
    localparam int REG_ADDR_W = 3;
    localparam int PHASE_W = 3;
    localparam int UCODE_ADDR_W = 10;

    localparam logic [XLEN-1:0] RESET_PC = 16'h0000;
    localparam logic [XLEN-1:0] PC_STEP  = 16'd2;

endpackage