`timescale 1ns / 1ps

`include "core_base.svh"

module decoder import core_base_pkg::*;
(
    input logic [XLEN-1:0] instr,
    input logic [ 3:0] CVZN,

    output logic [9:0] ucode_addr,

    output logic [2:0] rs0,
    output logic [2:0] rs1,
    output logic [2:0] rd,

    output logic [2:0] alu_func,
    output logic [2:0] alu_op_type,
    output logic [2:0] shift_count_d,

    output logic [5:0] imm6_d,
    output logic [8:0] imm9_d,

    output flag_t imm6,
    output logic int_flag,
    output logic check_branch,
    output logic read_carry
);

    logic [1:0] postf     = instr[12:11]; // postfix of encoding
    logic [2:0] inst_type = instr[15:13];


//__________________OP_TYPE____________________
    logic [3:0] op_type_d0 = instr[3:0];
    logic [3:0] op_type_d1 = instr[6:3];
    logic [3:0] op_type_d2 = instr[9:6];
    logic [3:0] op_type_d3 = instr[12:9];

//___________________BRANCH____________________
    logic [3:0] br_rel_flags_d = instr[12:9];
    logic [3:0] br_abs_flags_d = instr[3:0];


//____________________ALU______________________
    wire [2:0] alu_op_d0 = instr[8:6];
    wire [2:0] alu_op_d1 = instr[11:9];
    assign shift_count_d = inst[8:6];


//____________________DATA______________________
    wire [2:0] rs0_d = instr[5:3];
    wire [2:0] rs1_d = instr[8:6];
    wire [2:0] rd_d  = instr[2:0];

    assign imm6_d = instr[8:3];
    assign imm9_d = instr[8:0];


//__________________OP_PARSING______________________
    logic op0_op        = (inst_type == 0) && (postf == 2'b00);
    logic br_abs_d_op   = (inst_type == 0) && (postf == 2'b01);
    logic shifts_op     = (inst_type == 0) && (postf[0] == 1);
    logic op1_op        = (inst_type == 1);
    logic op2_op        = (inst_type == 2) && (XY == 2'b00);
    logic alu3_ind_op   = (inst_type == 2) && (XY == 2'b01);
    logic mem2_op       = (inst_type == 2) && (XY == 2'b10);
    logic alu2_op       = (inst_type == 2) && (XY == 2'b11);
    logic imm6_op       = (inst_type == 3);
    logic imm9_op       = (inst_type == 4);
    logic mem3_op       = (inst_type == 5) && (XY[0] == 0);
    logic alu3_op       = (inst_type == 5) && (XY[0] == 1);
    logic br_rel_n_d_op = (inst_type == 6);
    logic br_rel_p_d_op = (inst_type == 7);


    assign imm6_flag = imm6_op;
    assign int_flag = imm9_flag && op_type_d3[3:1] == 0;
    assign check_branch = br_abs_d || br_rel_n_d || br_rel_p_d;

    assign rs0 = imm6_flag ? rd_d : rs0_d;
    assign rs1 = (op1 || alu3_ind) ? rd_d : rs1_d;
    assign rd  = rd_d;

    wire [2:0] alu_op_type_tmp = {shifts, alu2, alu3 || alu3_ind};
    assign alu_op_type = |alu_op_type_tmp ? alu_op_type_tmp : 3'b001;

    wire arith_carry = shifts || alu3;

    logic [2:0] alu_func_tmp;
    assign alu_func = alu_func_tmp;
    always_comb begin
        if (arith_carry || alu2 || alu3_ind)
            if (alu2 || alu3_ind) alu_func_tmp = alu_op_d0;
            else alu_func_tmp = alu_op_d1;
        else if (imm6_flag && (op_type_d3[3:1] == 3'b111)) alu_func_tmp = 3'd6;
        else alu_func_tmp = 3'd5;
    end

    assign read_carry =    (alu3   && (alu_func_tmp == 3'd5 || alu_func_tmp == 3'd7))
                         || (shifts && (alu_func_tmp == 3'd5 || alu_func_tmp == 3'd6));

    // Branch logic
    wire br_go;
    branch_logic u_branch_logic (
        .cccc(br_abs_d ? br_abs_flags_d : br_rel_flags_d),
        .CVZN(CVZN),
        .go  (br_go)
    );
    wire br_abs     = br_abs_d && br_go;
    wire br_abs_nop = br_abs_d && !br_abs;
    wire br_rel_n   = br_rel_n_d && br_go;
    wire br_rel_p   = br_rel_p_d && br_go;
    wire br_rel_nop = (br_rel_n_d && !br_rel_n) || (br_rel_p_d && !br_rel_p);

    logic [3:0] direct_op_type;
    always_comb begin
        if      (br_rel_nop) direct_op_type = 4'h7;
        else if (br_abs_nop) direct_op_type = 4'h6;
        else if (br_rel_n) direct_op_type = 4'h5;
        else if (br_rel_p) direct_op_type = 4'h4;
        else if (alu3) direct_op_type = 4'h3;
        else if (alu3_ind) direct_op_type = 4'h2;
        else if (shifts || alu2) direct_op_type = 4'h1;
        else if (br_abs) direct_op_type = 4'h0;
        else direct_op_type = 4'h8;
    end

    always_comb begin
        if      (direct_op_type != 4'h8) ucode_addr = {phase, 3'h7, direct_op_type};
        else if (mem3) ucode_addr = {phase, 3'h6, op_type_d3};
        else if (imm9_flag) ucode_addr = {phase, 3'h5, op_type_d3};
        else if (imm6_flag) ucode_addr = {phase, 3'h4, op_type_d3};
        else if (mem2) ucode_addr = {phase, 3'h3, op_type_d2};
        else if (op2) ucode_addr = {phase, 3'h2, op_type_d2};
        else if (op1) ucode_addr = {phase, 3'h1, op_type_d1};
        else if (op0) ucode_addr = {phase, 3'h0, op_type_d0};
    end

endmodule
