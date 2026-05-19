`timescale 1ns / 1ps

`include "core_base.svh"

module decoder import core_base_pkg::*;
(
    input  logic [XLEN-1:0] instr,
    input  u_phase_t        phase,
    input  logic [3:0]      CVZN,

    output u_addr_t         ucode_addr,

    output reg_addr_t       rsi0,
    output reg_addr_t       rsi1,
    output reg_addr_t       rdi,

    output logic [2:0]      alu_func,
    output logic [2:0]      alu_op_type,
    output logic [2:0]      shamt,

    output logic [5:0]      imm6,
    output logic [8:0]      imm9,

    output flag_t           imm6_flag,
    output flag_t           carry_flag,
    output flag_t           is_int,
    output flag_t           is_branch
);
    wire [1:0] postf     = instr[12:11]; // postfix of encoding
    wire [2:0] inst_type = instr[15:13];


//__________________OP_TYPE____________________
    wire [3:0] op_type_d0 = instr[3:0];
    wire [3:0] op_type_d1 = instr[6:3];
    wire [3:0] op_type_d2 = instr[9:6];
    wire [3:0] op_type_d3 = instr[12:9];


//___________________BRANCH____________________
    wire [3:0] br_rel_cond_d = instr[12:9];
    wire [3:0] br_abs_cond_d = instr[3:0];


//____________________ALU______________________
    wire [2:0] alu_op_d0 = instr[8:6];
    wire [2:0] alu_op_d1 = instr[11:9];
    assign shamt = instr[8:6];


//____________________DATA______________________
    wire [2:0] rsi0_d = instr[5:3];
    wire [2:0] rsi1_d = instr[8:6];
    wire [2:0] rdi_d  = instr[2:0];

    assign imm6 = instr[8:3];
    assign imm9 = instr[8:0];


//__________________OP_PARSING___________________
    wire op0_d        = (inst_type == 0) && (postf == 2'b00);
    wire br_abs_d     = (inst_type == 0) && (postf == 2'b01);
    wire shifts_d     = (inst_type == 0) && (postf[1] == 1);
    wire op1_d        = (inst_type == 1);
    wire op2_d        = (inst_type == 2) && (postf == 2'b00);
    wire alu3_ind_d   = (inst_type == 2) && (postf == 2'b01);
    wire mem2_d       = (inst_type == 2) && (postf == 2'b10);
    wire alu2_d       = (inst_type == 2) && (postf == 2'b11);
    wire imm6_d       = (inst_type == 3);
    wire imm9_d       = (inst_type == 4);
    wire mem3_d       = (inst_type == 5) && (postf[1] == 0);
    wire alu3_d       = (inst_type == 5) && (postf[1] == 1); // check and fix this
    wire br_rel_n_d   = (inst_type == 6);
    wire br_rel_p_d   = (inst_type == 7);


//__________________REGISTERS______________________
    assign rsi0 = imm6_d ? rdi_d : rsi0_d;
    assign rsi1 = (op1_d || alu3_ind_d) ? rdi_d : rsi1_d;
    assign rdi  = rdi_d;


//__________________ALU_FUNC_______________________
    logic [2:0] _alu_func;
    always_comb begin
        if (shifts_d || alu2_d || alu3_d || alu3_ind_d) begin
            if (alu2_d || alu3_ind_d) _alu_func = alu_op_d0;
            else _alu_func = alu_op_d1;
        end
        else if (imm6_d && (op_type_d3[3:1] == 3'b111)) _alu_func = 3'd6;
        else _alu_func = 3'd5;
    end
    assign alu_func = _alu_func;


//__________________SET_FLAGS______________________
    wire [2:0] alu_op_type_raw = {shifts_d, alu2_d, alu3_d || alu3_ind_d};
    assign alu_op_type = |alu_op_type_raw ? alu_op_type_raw : 3'b001;


    assign imm6_flag = imm6_d;
    assign is_int = imm9_d && op_type_d3[3:1] == 0;
    assign is_branch = br_abs_d || br_rel_n_d || br_rel_p_d;
    assign carry_flag =    (alu3_d   && (_alu_func == 3'd5 || _alu_func == 3'd7))
                        || (shifts_d && (_alu_func == 3'd5 || _alu_func == 3'd6));

//___________________BRANCH_________________________
    wire br_go;
    wire [3:0] br_cond = br_abs_d ? br_abs_cond_d : br_rel_cond_d;

    branch_logic u_branch_logic (
        .cond(br_cond),
        .CVZN(CVZN),
        .go  (br_go)
    );
    
    wire br_abs     = br_abs_d && br_go;
    wire br_abs_nop = br_abs_d && !br_go;

    wire br_rel_n   = br_rel_n_d && br_go;
    wire br_rel_p   = br_rel_p_d && br_go;
    wire br_rel_nop = (br_rel_n_d || br_rel_p_d) && !br_go;
    


//_________________UCODE_ADDR________________________
    logic [3:0] direct_op_type;
    always_comb begin
        if      (br_rel_nop)         direct_op_type = 4'h7;
        else if (br_abs_nop)         direct_op_type = 4'h6;
        else if (br_rel_n)           direct_op_type = 4'h5;
        else if (br_rel_p)           direct_op_type = 4'h4;
        else if (alu3_d)             direct_op_type = 4'h3;
        else if (alu3_ind_d)         direct_op_type = 4'h2;
        else if (shifts_d || alu2_d) direct_op_type = 4'h1;
        else if (br_abs_d)           direct_op_type = 4'h0;
        else                         direct_op_type = 4'h8;
    end

    always_comb begin
        if (direct_op_type != 4'h8) ucode_addr = {phase, UCODE_DIRECT,  direct_op_type};
        else if (mem3_d)            ucode_addr = {phase, UCODE_MEM3,    op_type_d3};
        else if (imm9_d)            ucode_addr = {phase, UCODE_IMM9,    op_type_d3};
        else if (imm6_d)            ucode_addr = {phase, UCODE_IMM6,    op_type_d3};
        else if (mem2_d)            ucode_addr = {phase, UCODE_MEM2,    op_type_d2};
        else if (op2_d)             ucode_addr = {phase, UCODE_OP2,     op_type_d2};
        else if (op1_d)             ucode_addr = {phase, UCODE_OP1,     op_type_d1};
        else if (op0_d)             ucode_addr = {phase, UCODE_OP0,     op_type_d0};
        else                        ucode_addr = 'x;
    end

endmodule // decoder
