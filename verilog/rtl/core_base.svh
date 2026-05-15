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

    typedef enum logic [2:0] {
        UCODE_OP0    = 3'h0,
        UCODE_OP1    = 3'h1,
        UCODE_OP2    = 3'h2,
        UCODE_MEM2   = 3'h3,
        UCODE_IMM6   = 3'h4,
        UCODE_IMM9   = 3'h5,
        UCODE_MEM3   = 3'h6,
        UCODE_DIRECT = 3'h7
    } ucode_sel_e;

    typedef struct packed {
        logic cut;               // [27] end of instruction, phase reset
        logic word;              // [26] 16-bit memory access
        logic sp_latch;          // [25] D-bus → SP
        logic sp_inc;            // [24] SP += 2
        logic sp_dec;            // [23] SP -= 2
        logic sp_asrtd;          // [22] SP → D-bus
        logic sp_asrt0;          // [21] SP → bus 0
        logic sign_extend;       // [20] sign extension
        logic read;              // [19] memory read (otherwise write)
        logic r_latch;           // [18] D-bus → register
        logic r_asrtd;           // [17] register → D-bus
        logic r_asrt1;           // [16] register → bus 1
        logic r_asrt0;           // [15] register → bus 0
        logic ps_latch_word;     // [14] full word → PS
        logic ps_latch_flags;    // [13] flags only → PS
        logic ps_asrtd;          // [12] PS → D-bus
        logic pc_latch;          // [11] D-bus → PC
        logic pc_inc;            // [10] PC += 2
        logic pc_asrtd;          // [9]  PC → D-bus
        logic pc_asrt0;          // [8]  PC → bus 0
        logic mem;               // [7]  enable memory access
        logic imm_shift;         // [6]  shift immediate left by 1
        logic imm_extend_neg;    // [5]  sign-extend immediate
        logic imm_asrtd;         // [4]  immediate → D-bus
        logic imm_asrt1;         // [3]  immediate → bus 1
        logic fp_asrt0;          // [2]  FP (r7) → bus 0
        logic data;              // [1]  memory data signal
        logic alu_asrtd;         // [0]  ALU result → D-bus
    } ucode_word_t;

// ====================== ALU =========================
    typedef enum logic [2:0] {
        ALU3  = 3'b001,
        ALU2  = 3'b010,
        SHIFT  = 3'b100
    } alu_op_type_e;

    typedef enum logic [2:0] {
        ALU3_AND  = 3'd0,
        ALU3_OR   = 3'd1,
        ALU3_XOR  = 3'd2,
        ALU3_BIC  = 3'd3,
        ALU3_ADD  = 3'd4,
        ALU3_ADC  = 3'd5,
        ALU3_SUB  = 3'd6,
        ALU3_SUBC = 3'd7
    } alu3_func_e;

    typedef enum logic [2:0] {
        ALU2_NEG = 3'd0,
        ALU2_NOT = 3'd1,
        ALU2_SXT = 3'd2,
        ALU2_SCL = 3'd3
    } alu2_func_e;

    typedef enum logic [2:0] {
        SHIFT_SHL  = 3'd0,
        SHIFT_SHR  = 3'd1,
        SHIFT_SHRA = 3'd2,
        SHIFT_ROL  = 3'd3,
        SHIFT_ROR  = 3'd4,
        SHIFT_RCL  = 3'd5,
        SHIFT_RCR  = 3'd6
    } shift_func_e;

endpackage
