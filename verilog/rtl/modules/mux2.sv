module mux2 #(parameter int W=16)(
  input  logic [W-1:0] d0, d1,
  input  logic sel,
  output logic [W-1:0] y
);
  always_comb y = sel ? d1 : d0;
endmodule