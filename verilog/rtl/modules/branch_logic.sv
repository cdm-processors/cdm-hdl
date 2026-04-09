`timescale 1ns / 1ps

module branch_logic
(
    input   logic [3:0] cond,
    input   logic [3:0] CVZN,

    output  logic       go
);
    logic C, V, Z, N;
    assign {C, V, Z, N} = CVZN;

    logic reverse = cond[0];
    logic dcsn;
    assign go = dcsn ^ reverse;

    always_comb begin
        unique case (cond[3:1])
            0: dcsn = Z;
            1: dcsn = C;
            2: dcsn = N;
            3: dcsn = V;
            4: dcsn = C & (~Z) & 1;
            5: dcsn = ~(N ^ V) & 1;
            6: dcsn = (~Z) & ~(N ^ V) & 1;
            7: dcsn = 1;
        endcase
    end
endmodule
