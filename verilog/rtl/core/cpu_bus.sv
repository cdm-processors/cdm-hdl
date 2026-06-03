`include "core_base.svh"

module cpu_bus
  import core_base_pkg::*;
(
    input ucode_word_t ucode,
    input u_phase_t phase,

    //Registers
    input reg_t pc,
    input reg_t ps,
    input reg_t sp,

    //Decoder data
    input logic  [5:0] imm6,
    input logic  [8:0] imm9,
    input flag_t       imm6_flag,
    input flag_t       is_int,
    input flag_t       is_branch,
    input flag_t       is_jsr,

    //Register file data
    input reg_t rs0,
    input reg_t rs1,
    input reg_t rd_out,
    input reg_t fp,

    //Mem data
    input data_t mem_data,

    //ALU data
    input data_t alu_result,

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
      .imm_extend_neg(ucode.imm_extend_neg),
      .imm_shift     (ucode.imm_shift),
      .imm           (imm)
  );

  flag_t pc_push_return_addr;
  data_t pc_observed_value;
  data_t sp_observed_value;

  always_comb begin
    pc_push_return_addr = is_jsr && ucode.pc_asrtd;
    pc_observed_value = pc_push_return_addr ? pc + 16'd4 : pc + 16'd2;
    sp_observed_value = ucode.sp_dec ? sp - 16'd2 : sp;

    if (ucode.fp_asrt0) alu_bus1 = fp;  //register[7]
    else if (ucode.pc_asrt0) alu_bus1 = pc_observed_value;
    else if (ucode.r_asrt0) alu_bus1 = rs0;
    else if (ucode.sp_asrt0) alu_bus1 = sp_observed_value;
    else alu_bus1 = 16'b0;

    if (ucode.imm_asrt1) alu_bus2 = imm;
    else if (ucode.r_asrt1) alu_bus2 = rs1;
    else alu_bus2 = 16'b0;

    if (ucode.r_asrtd) data_bus = rd_out;
    else if (ucode.imm_asrtd) data_bus = imm;
    else if (ucode.mem && ucode.read) data_bus = mem_data;
    else if (ucode.sp_asrtd) data_bus = sp_observed_value;
    else if (ucode.pc_asrtd) data_bus = pc_observed_value;
    else if (ucode.alu_asrtd) data_bus = alu_result;
    else if (ucode.ps_asrtd) data_bus = ps;
    else data_bus = '0;
  end

endmodule
