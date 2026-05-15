`timescale 1ns / 1ps
 
`include "core_base.svh"

module imm_decoder import core_base_pkg::*; (
    input logic [5:0] imm6,
    input logic [8:0] imm9,
    input u_phase_t phase,
    input flag_t is_int,
    input flag_t imm6_flag,
    input flag_t imm_extend_neg,
    input flag_t imm_shift,

    output reg_t imm
);

    reg_t extended_imm;

    always_comb begin
        if (imm6_flag) begin
            if (imm_extend_neg) begin
                extended_imm = {{10{1'b1}}, imm6};
            end else begin
                extended_imm = {{10{1'b0}}, imm6};
            end
        end else begin
            if (imm_extend_neg) begin
                extended_imm = {{7{1'b1}}, imm9};
            end else begin
                extended_imm = {{7{1'b0}}, imm9};
            end
        end
    end

    reg_t shifted_imm;
    assign imm = shifted_imm;

    always_comb begin
        if (is_int) begin
            if (phase == 3'd3) begin          // phase[0] == 1
                shifted_imm = (extended_imm << 2) + 16'd2;
            end else if (phase == 3'd2) begin // phase[0] == 0
                shifted_imm = extended_imm << 2;
            end else begin
                shifted_imm = '0;
            end
        end else begin
            if (imm_shift) begin 
                shifted_imm = extended_imm << 1;
            end else begin
                shifted_imm = extended_imm;
            end
        end
    end

endmodule // imm_decoder