package core_base_pkg;

// ===================== CONSTANTS =====================
    localparam int XLEN = 16;

    localparam logic [XLEN-1:0] RESET_PC = 16'b0;
    localparam logic [XLEN-1:0] PC_STEP  = 16'd2;

// ====================== TYPES =====================
    typedef logic flag_t;


// ===================== REG_FILE ======================
    localparam int REG_CNT = 8;
    localparam int REG_ADDR_W = ($clog2(REG_CNT));
    typedef logic[REG_ADDR_W-1:0] reg_addr_t;
    typedef logic[XLEN-1:0] reg_t;

// ====================== UCODE ========================
    localparam int PHASE_W = 3;
    localparam int UCODE_ADDR_W = 10;

    typedef logic u_sig_t; 
    typedef logic[PHASE_W-1:0] u_phase_t;
    typedef logic[UCODE_ADDR_W-1:0] u_addr_t;

endpackage
