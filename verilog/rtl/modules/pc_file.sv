module pc_file #(
    parameter int  XLEN = core_base_pkg::XLEN,
    parameter logic [XLEN-1:0] RESET_PC = core_base_pkg::RESET_PC,
    parameter logic [XLEN-1:0] STEP     = core_base_pkg::PC_STEP
) (
    input  logic            i_clk,
    input  logic            i_rst,

    // Control
    input  logic            i_hold,
    input  logic            i_inc,
    input  logic            i_load,
    input  logic [XLEN-1:0] i_load_data,

    // State
    output logic [XLEN-1:0] o_pc,
    output logic [XLEN-1:0] o_pc_next_inc,
    output logic            o_unaligned
);

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            o_pc <= RESET_PC;
        end else if (!i_hold) begin
            if (i_load) begin
                o_pc <= i_load_data;
            end else if (i_inc) begin
                o_pc <= o_pc + STEP;
            end
        end
    end

    assign o_pc_next_inc = o_pc + STEP;
    assign o_unaligned   = o_pc[0];

endmodule