package core_base_pkg;

    localparam int XLEN = 16;
    localparam int PHASE_W = 3;
    localparam int UCODE_ADDR_W = 10;

    localparam logic [XLEN-1:0] RESET_PC = 16'b0;
    localparam logic [XLEN-1:0] PC_STEP  = 16'd2;

    localparam int REG_CNT = 8;
    localparam int REG_ADDR_W = ($clog2(REG_CNT));
    // typedef logic [XLEN-1:0] reg_t;
    // typedef logic[REG_ADDR_W-1:0] reg_addr_t // maybe?


    typedef logic sig_t; // ucode signal
    typedef logic flag_t;
endpackage
