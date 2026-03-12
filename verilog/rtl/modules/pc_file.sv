`timescale 1ns / 1ps
import core_base_pkg::*;

module program_counter 
#(
    parameter int WIDTH = XLEN,
    parameter logic [WIDTH-1:0] PC_START_ADDR = '0,
    parameter logic [WIDTH-1:0] PC_INCR = 16'd4
)(
    input  logic clk,
    input  logic rst,
    input  logic br_taken,
    input  logic [WIDTH-1:0] pc_br,
    output logic [WIDTH-1:0] pc
);

    logic [WIDTH-1:0] assign_pc;

    always_comb begin
        if (br_taken) begin
            assign_pc = pc_br;
        end else begin
            assign_pc = pc + PC_INCR;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= PC_START_ADDR;
        end else begin
            pc <= assign_pc;
        end
    end

endmodule : program_counter
