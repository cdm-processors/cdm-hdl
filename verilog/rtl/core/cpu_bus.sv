`include "core_base.svh"

module cpu_bus
  import core_base_pkg::*;
(
    input ucode_word_t ucode,
    input u_phase_t phase,

    //Registers
    input reg_t pc,
    input reg_t ps,

    //Decoder data
    input logic  [5:0] imm6,
    input logic  [8:0] imm9,
    input flag_t       imm6_flag,
    input flag_t       is_int,
    input flag_t       is_branch,
    input flag_t       is_branch,
    input flag_t       is_jsr,

    //Register file data
    input reg_t rs1,
    input reg_t rs2,
    input reg_t rd,
    input reg_t fp,

    //Mem data
    data_t mem_data,

    output data_t alu_bus1,
    output data_t alu_bus2,
    output data_t data_bus
);

  data_t imm;
  imm_decoder u_imm_decoder (
      .imm6          (imm6),
      .imm9          (imm9),
      .phase         (phase),
      .is_int        (is_int),
      .imm6_flag     (imm6_flag),
      .imm_extend_neg(imm_extend_neg),
      .imm_shift     (imm_shift),
      .imm           (imm)
  );

  always_comb begin
    flag_t dec_pc_asrt_inc = jsr && ucode.pc_asrt0;
    data_t dec_pc_observed_value = dec_pc_asrt_inc ? dec_pc + 4 : dec_pc + 2;

    data_t dec_sp_observed_value = ucode.sp_asrt0 ? sp - 2 : sp;

    if (ucode.fp_asrt0) alu_bus1 = fp;  //register[7]
    else if (ucode.pc_asrt0) alu_bus1 = dec_pc_observed_value;
    else if (ucode.r_asrt0) alu_bus1 = rs0;
    else if (ucode.sp_asrt0) alu_bus1 = dec_sp_observed_value;
    else alu_bus1 = 16'b0;

    if (ucode.imm_asrt1) alu_bus2 = imm;
    else if (ucode.r_asrt1) alu_bus2 = rs1;
    else alu_bus2 = 16'b0;

    if (ucode.imm_asrtd) data_bus = imm;
    else if (ucode.pc_asrtd) data_bus = dec_pc_observed_value;
    else if (ucode.ps_asrtd) data_bus = ps;
    else if (ucode.r_asrtd) data_bus = rd;
    else if (ucode.sp_asrtd) data_bus = dec_sp_observed_value;
    else data_bus = 16'b0;
  end

endmodule
