`include "core_base.svh"

module core_sequencer
  import core_base_pkg::*;
(
    input  logic       clk,
    input  logic       rst,

    input  flag_t      core_stopped,         // halted/waiting/fault -> freeze
    input  flag_t      stall,                // BRAM read in flight -> hold this cycle
    input  flag_t      cut,                  // last microstep of the instruction
    input  flag_t      has_internal_exc,     // internal exception fired this cycle
    input  logic [5:0] next_exc_vector,      // vector for that exception
    input  flag_t      taking_external_irq,  // accept an external interrupt now
    input  logic [5:0] irq_vector,           // external interrupt vector
    input  data_t      pc,                   // current PC (from pc_file)
    input  data_t      fetched_instr,        // word read from memory at pc

    output u_phase_t   phase,                // microstep counter
    output flag_t      fetch_state,          // 1 = fetch boundary, 0 = executing
    output data_t      instr_reg,            // instruction currently executed
    output data_t      instr_pc,             // address of instr_reg
    output flag_t      startup,              // still entering power-on reset
    output flag_t      exc_pending,          // an internal exception is queued
    output flag_t      exc_entry             // current instr is an exception/irq entry
);

  localparam data_t VIRTUAL_RESET_INSTR = 16'h8200;
  localparam data_t VIRTUAL_INT_BASE    = 16'h8000;

  logic [5:0] exc_vector;     // which vector to enter
  data_t      exc_fault_pc;   // PC of the faulting instruction

  always_ff @(posedge clk) begin
    if (rst) begin
      phase <= '0;
      fetch_state <= 1'b1;
      instr_reg <= '0;
      instr_pc <= '0;
      startup <= 1'b1;
      exc_pending <= 1'b0;
      exc_entry <= 1'b0;
      exc_vector <= '0;
      exc_fault_pc <= '0;
    end else if (has_internal_exc) begin
      phase <= '0;
      fetch_state <= 1'b1;
      exc_pending <= 1'b1;
      exc_vector <= next_exc_vector;
      exc_fault_pc <= instr_pc;
      exc_entry <= 1'b0;
    end else if (!core_stopped && !stall) begin
      if (fetch_state) begin
        if (startup) begin
          instr_reg <= VIRTUAL_RESET_INSTR;
          instr_pc <= '0;
          startup <= 1'b0;
          exc_entry <= 1'b0;
        end else if (exc_pending) begin
          instr_reg <= VIRTUAL_INT_BASE | {10'd0, exc_vector};
          instr_pc <= exc_fault_pc;
          exc_pending <= 1'b0;
          exc_entry <= 1'b1;
        end else if (taking_external_irq) begin
          instr_reg <= VIRTUAL_INT_BASE | {10'd0, irq_vector};
          instr_pc <= pc;
          exc_entry <= 1'b1;
        end else begin
          instr_reg <= fetched_instr;
          instr_pc <= pc;
          exc_entry <= 1'b0;
        end

        phase <= '0;
        fetch_state <= 1'b0;
      end else if (cut) begin
        phase <= '0;
        fetch_state <= 1'b1;
      end else begin
        phase <= phase + 1'b1;
      end
    end
  end

endmodule  // core_sequencer
