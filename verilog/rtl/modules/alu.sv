`timescale 1ns / 1ps

`include "core_base.svh"

module alu import core_base_pkg::*; (
    input logic [15:0] A, 
    input logic [15:0] B,
    input logic carry_in, 

    output logic [15:0] R,
    output logic [ 3:0] CVZN,

    input logic [2:0] op_type,
    input logic [2:0] func, 
    input logic [2:0] shamt 
);
  function automatic checkC(input [16:0] i);
    checkC = i[16];
  endfunction

  function automatic checkV(input [15:0] rd, rs0, rs1);  // TODO: check this
    checkV = ((rd[15] != 0) && (rs0[15] == 0) && (rs1[15] == 0)) ||
             ((rd[15] == 0) && (rs0[15] != 0) && (rs1[15] != 0)) ;
  endfunction


  logic C;
  logic V;
  logic Z;
  logic N;
  assign CVZN[3:0] = {C, V, Z, N};

  logic [16:0] wA;
  logic [16:0] wB;
  assign wA =  {1'd0, A};
  assign wB = {1'd0, B};

  logic [16:0] wR;
  assign Z = (R == 16'd0);
  assign N = R[15];
  assign R = wR[15:0];


  logic [4:0] w_shamt;
  assign w_shamt = 5'd1 + {2'b0, shamt};

  always_comb begin
    wR = '0;
    C  = 0;
    V  = 0;
    case (op_type)
      ALU3: begin
        case (func)
          ALU3_AND: begin
            wR = wA & wB;
          end
          ALU3_OR: begin
            wR = wA | wB;
          end
          ALU3_XOR: begin
            wR = wA ^ wB;
          end
          ALU3_BIC: begin
            wR = wA & (~wB);
          end
          ALU3_ADD: begin
            wR = A + B;
            C  = checkC(wR);
            V  = checkV(R, A, B);
          end
          ALU3_ADC: begin
            wR = wA + wB + {16'd0, carry_in};
            C  = checkC(wR);
            V  = checkV(R, A, B + {15'd0, carry_in});  // TODO: maybe there's overflow in second arg
          end
          ALU3_SUB: begin  // SUB
            wR = wA + (~wB) + 1;
            C  = checkC(wR);
            V  = checkV(R, A, (~B) + 1);  // TODO: maybe there's overflow in second arg
          end
          ALU3_SUBC: begin  // SUBC
            wR = wA + (~wB) + {16'd0, carry_in};
            C  = checkC(wR);
            V  = checkV(R, A, (~B) + {15'd0, carry_in});  // TODO: maybe there's overflow in second arg
          end
        endcase
      end
      ALU2: begin
        case (func)
          ALU2_NEG: begin
            wR = (~wA) + 1;
            C  = checkC(wR);
            V  = A == 16'h8000;
          end
          ALU2_NOT: begin
            wR = (~wA);
          end
          ALU2_SXT: begin
            wR = {1'd0, {8{wA[7]}}, wA[7:0]};
          end
          ALU2_SCL: begin
            wR = wA & 17'h00FF;
          end
        endcase
      end
      SHIFT: begin
        case (func)
          SHIFT_SHL: begin
            wR = wA << w_shamt;
            C  = wA[16-w_shamt];
          end
          SHIFT_SHR: begin
            wR = wA >> w_shamt;
            C  = wA[w_shamt-1];
          end
          SHIFT_SHRA: begin
            wR = {1'b0, (A >>> w_shamt) | ({16{A[15]}} << (16 - w_shamt))};
            C  = wA[w_shamt-1];
          end
          SHIFT_ROL: begin
            wR = {1'b0, (A << w_shamt) | {A >> (16 - w_shamt)}};
            C  = wA[16-w_shamt];
          end
          SHIFT_ROR: begin
            wR = {1'b0, (A >> w_shamt) | {A << (16 - w_shamt)}};
            C  = wA[w_shamt-1];
          end
          SHIFT_RCL: begin
            wR = {
              1'b0,
              (A << w_shamt) | {{15'd0, carry_in} << (w_shamt - 1)} |  {A >> (16 - w_shamt + 1)}
            };
            C = wA[16-w_shamt];
          end
          SHIFT_RCR: begin
            wR = {
              1'b0,
              (A >> w_shamt) | {{15'd0, carry_in} << (16 - w_shamt)} | {A << (16 - w_shamt + 1)}
            };
            C = wA[w_shamt-1];
          end
        endcase
      end
    endcase
  end


endmodule // alu
