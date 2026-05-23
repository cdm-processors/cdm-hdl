module rams_tdp_rf_rf #(
    parameter int WIDTH  = 16,
    parameter int ADDR_W = 10,
    parameter int DEPTH  = 1 << ADDR_W
)(
    input  logic              clka,
    input  logic              clkb,
    input  logic              ena,
    input  logic              enb,
    input  logic              wea,
    input  logic              web,
    input  logic [ADDR_W-1:0] addra,
    input  logic [ADDR_W-1:0] addrb,
    input  logic [WIDTH-1:0]  dia,
    input  logic [WIDTH-1:0]  dib,
    output logic [WIDTH-1:0]  doa,
    output logic [WIDTH-1:0]  dob
);

    (* ram_style = "block" *) 
    logic [WIDTH-1:0] ram [DEPTH];

    always_ff @(posedge clka) begin
        if (ena) begin
            if (wea) begin
                ram[addra] <= dia;
            end
            doa <= ram[addra];
        end
    end

    always_ff @(posedge clkb) begin
        if (enb) begin
            if (web) begin
                ram[addrb] <= dib;
            end
            dob <= ram[addrb];
        end
    end
endmodule