`timescale 1ns / 1ps

module alu (
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
    case (op_type)
      default: begin
        wR = 0;
        C  = 0;
        V  = 0;
      end
      3'b001: begin  // ALU_3
        case (func)
          0: begin  // AND
            C  = 0;
            V  = 0;
            wR = wA & wB;
          end
          1: begin  // OR
            C  = 0;
            V  = 0;
            wR = wA | wB;
          end
          2: begin  // XOR
            C  = 0;
            V  = 0;
            wR = wA ^ wB;
          end
          3: begin  // BIC
            C  = 0;
            V  = 0;
            wR = wA & (~wB);
          end
          4: begin  // ADD
            wR = A + B;
            C  = checkC(wR);
            V  = checkV(R, A, B);
          end
          5: begin  // ADC
            wR = wA + wB + {16'd0, carry_in};
            C  = checkC(wR);
            V  = checkV(R, A, B + {15'd0, carry_in});  // TODO: maybe there's overflow in second arg
          end
          6: begin  // SUB
            wR = wA + (~wB) + 1;
            C  = checkC(wR);
            V  = checkV(R, A, (~B) + 1);  // TODO: maybe there's overflow in second arg
          end
          7: begin  // SUBC
            wR = wA + (~wB) + {16'd0, carry_in};
            C  = checkC(wR);
            V  = checkV(R, A, (~B) + {15'd0, carry_in});  // TODO: maybe there's overflow in second arg
          end
        endcase
      end
      3'b010: begin  // ALU_2
        case (func)
          default: begin
            wR = 0;
            C  = 0;
            V  = 0;
          end
          0: begin  // NEG
            wR = (~wA) + 1;
            C  = checkC(wR);
            V  = A == 16'h8000;
          end
          1: begin  // NOT
            wR = (~wA);
            C  = 0;
            V  = 0;
          end
          2: begin  // SXT
            wR = {1'd0, {8{wA[7]}}, wA[7:0]};
            C  = 0;
            V  = 0;
          end
          3: begin  // SCL
            wR = wA & 17'h00FF;
            C  = 0;
            V  = 0;
          end
        endcase
      end
      3'b100: begin
        V = 0;
        case (func)
          default: begin
            wR = 0;
            C  = 0;
          end
          0: begin  // SHL
            wR = wA << w_shamt;
            C  = wA[16-w_shamt];
          end
          1: begin  // SHR
            wR = wA >> w_shamt;
            C  = wA[w_shamt-1];
          end
          2: begin  // SHRA
            wR = {1'b0, (A >>> w_shamt) | ({16{A[15]}} << (16 - w_shamt))};
            C  = wA[w_shamt-1];
          end
          3: begin  // ROL
            wR = {1'b0, (A << w_shamt) | {A >> (16 - w_shamt)}};
            C  = wA[16-w_shamt];
          end
          4: begin  // ROR
            wR = {1'b0, (A >> w_shamt) | {A << (16 - w_shamt)}};
            C  = wA[w_shamt-1];
          end
          5: begin  // RCL
            wR = {
              1'b0,
              (A << w_shamt) | {{15'd0, carry_in} << (w_shamt - 1)} |  {A >> (16 - w_shamt + 1)}
            };
            C = wA[16-w_shamt];
          end
          6: begin  // RCR
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
