`include "core_base.svh"

module core
  import core_base_pkg::*;
(
    input logic clk,
    input logic rst,
    input flag_t irq,
    output flag_t int_en,
    output logic [1:0] status
);

  logic [XLEN-1:0] instr;

  flag_t data_en;
  flag_t data_wr;

  ucode_word_t uword;

  u_phase_t phase;

  data_t pc;
  data_t pc_next;
  data_t pc_load_data;

  u_addr_t ucode_addr;

  reg_addr_t rsi0;
  reg_addr_t rsi1;
  reg_addr_t rdi;

  data_t rs0;
  data_t rs1;
  data_t rd_out;
  data_t fp;

  data_t data_bus;
  flag_t rf_we;

  logic [2:0] alu_func;
  logic [2:0] alu_op_type;
  logic [2:0] shamt;

  logic [5:0] imm6;
  logic [8:0] imm9;

  flag_t imm6_flag;
  flag_t carry_flag;
  flag_t is_int;
  flag_t is_branch;
  flag_t is_jsr;
  flag_t is_halt;
  flag_t is_wait;
  flag_t is_ei;
  flag_t is_di;

  flag_t halted;
  flag_t waiting;
  flag_t core_stopped;

  assign core_stopped = halted || waiting;

  always_comb begin
    if (halted) status = 2'd2;
    else if (waiting) status = 2'd1;
    else status = 2'd0;
  end

  logic [3:0] flags;

  data_t fetched_instr;
  data_t instr_reg;
  data_t instr_pc;
  flag_t fetch_state;
  ucode_word_t decoded_uword;

  assign instr = instr_reg;

  flag_t pc_hold;
  flag_t pc_inc;
  flag_t pc_load;
  flag_t pc_unaligned;

  assign pc_hold = 1'b0;
  assign pc_inc = !core_stopped && (fetch_state || uword.pc_inc);
  assign pc_load = uword.pc_latch;
  assign pc_load_data = data_bus;

  data_t sp;
  data_t ps;
  data_t mem_data;
  data_t alu_bus1;
  data_t alu_bus2;

  assign data_en = uword.mem;
  assign data_wr = uword.mem && !uword.read;

  assign flags = ps[3:0];
  assign int_en = ps[15];

  flag_t interrupt_pending;

  assign interrupt_pending = irq && int_en;

  data_t alu_result;
  logic [3:0] alu_flags;
  flag_t alu_carry_in;

  assign alu_carry_in = carry_flag ? flags[3] : 1'b0;

  decoder u_decoder (
    .instr(instr),
    .phase(phase),
    .CVZN(flags),

    .ucode_addr(ucode_addr),

    .rsi0(rsi0),
    .rsi1(rsi1),
    .rdi(rdi),

    .alu_func(alu_func),
    .alu_op_type(alu_op_type),
    .shamt(shamt),

    .imm6(imm6),
    .imm9(imm9),

    .imm6_flag(imm6_flag),
    .carry_flag(carry_flag),
    .is_int(is_int),
    .is_branch(is_branch),
    .is_jsr(is_jsr),

    .is_halt(is_halt),
    .is_wait(is_wait),
    .is_ei(is_ei),
    .is_di(is_di)
  );

  gen_ucode u_gen_ucode (
    .addr(ucode_addr),
    .S(decoded_uword)
  );

  assign uword = (fetch_state || core_stopped) ? '0 : decoded_uword;

  assign rf_we = uword.r_latch;

  reg_file_m u_reg_file (
      .clk(clk),
      .we(rf_we),

      .rsi0(rsi0),
      .rs0(rs0),

      .rsi1(rsi1),
      .rs1(rs1),

      .rdi(rdi),
      .rd_in(data_bus),
      .rd_out(rd_out),

      .fp(fp)
  );

  cpu_bus u_cpu_bus (
      .ucode(uword),
      .phase(phase),

      .pc(instr_pc),
      .ps(ps),
      .sp(sp),

      .imm6(imm6),
      .imm9(imm9),
      .imm6_flag(imm6_flag),
      .is_int(is_int),
      .is_branch(is_branch),
      .is_jsr(is_jsr),

      .rs0(rs0),
      .rs1(rs1),
      .rd_out(rd_out),
      .fp(fp),

      .mem_data(mem_data),

      .alu_result(alu_result),

      .alu_bus1(alu_bus1),
      .alu_bus2(alu_bus2),
      .data_bus(data_bus)
  );

  alu u_alu (
      .A(alu_bus1),
      .B(alu_bus2),
      .carry_in(alu_carry_in),

      .op_type(alu_op_type),
      .func(alu_func),
      .shamt(shamt),

      .R(alu_result),
      .CVZN(alu_flags)
  );

  pc_file #(
      .XLEN    (core_base_pkg::XLEN),
      .RESET_PC(core_base_pkg::RESET_PC),
      .STEP    (core_base_pkg::PC_STEP)
  ) u_pc_file (
      .i_clk(clk),
      .i_rst(rst),

      .i_hold     (pc_hold),
      .i_inc      (pc_inc),
      .i_load     (pc_load),
      .i_load_data(pc_load_data),

      .o_pc       (pc),
      .o_pc_next  (pc_next),
      .o_unaligned(pc_unaligned)
  );

  // ===================== MEMORY ======================
  //instance of memory
  memory u_memory (
      .clk(clk),

      .instr_addr(pc),
      .instr_en(1'b1),
      .instr(fetched_instr),

      .data_en(data_en),
      .data_wr(data_wr),
      .data_addr(alu_result),
      .data_in(data_bus),
      .data_out(mem_data)
  );

  
  always_ff @(posedge clk) begin
    if (rst) begin
      phase <= '0;
      fetch_state <= 1'b1;
      instr_reg <= '0;
      instr_pc <= '0;
    end else if (!core_stopped) begin
       if (fetch_state) begin
         instr_reg <= fetched_instr;
         instr_pc <= pc;
         phase <= '0;
         fetch_state <= 1'b0;
       end else if (uword.cut) begin
         phase <= '0;
         fetch_state <= 1'b1;
       end else begin
         phase <= phase + 1'b1;
       end
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      ps <= '0;
    end else if (uword.ps_latch_word) begin
      ps <= data_bus;
    end else if (!fetch_state && uword.cut && is_ei) begin
      ps[15] <= 1'b1;
    end else if (!fetch_state && uword.cut && is_di) begin
      ps[15] <= 1'b0;
    end else if (uword.ps_latch_flags) begin
      ps[3:0] <= alu_flags;
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      halted <= 1'b0;
      waiting <= 1'b0;
    end else begin
      if (!fetch_state && uword.cut && is_halt) begin
        halted <= 1'b1;
      end

      if (irq) begin
        waiting <= 1'b0;
      end else if (!fetch_state && uword.cut && is_wait) begin
        waiting <= 1'b1;
      end
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      sp <= '0;
    end else if (uword.sp_latch) begin
      sp <= data_bus;
    end else if (uword.sp_inc) begin
      sp <= sp + 16'd2;
    end else if (uword.sp_dec) begin
      sp <= sp - 16'd2;
    end
  end


endmodule  // core
