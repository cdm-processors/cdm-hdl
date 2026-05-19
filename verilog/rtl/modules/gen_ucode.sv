`timescale 1ns / 1ps
`include "core_base.svh"
module gen_ucode import core_base_pkg::*; (
    input u_addr_t addr,
    output ucode_word_t S
);
    wire [6:0] rule = addr[6:0];
    u_phase_t phase;

    assign phase = addr[9:7];

    always_comb begin
        S = '0;

        case (rule)
            7'd4: begin  // halt
                case (phase)
                    3'd0: begin  // 28'hc000000: word
                        S.cut = 1'b1;
                        S.word = 1'b1;
                    end
                endcase
            end
            7'd5: begin  // wait
                case (phase)
                    3'd0: begin  // 28'hc000000: word
                        S.cut = 1'b1;
                        S.word = 1'b1;
                    end
                endcase
            end
            7'd6: begin  // ei
                case (phase)
                    3'd0: begin  // 28'hc000000: word
                        S.cut = 1'b1;
                        S.word = 1'b1;
                    end
                endcase
            end
            7'd7: begin  // di
                case (phase)
                    3'd0: begin  // 28'hc000000: word
                        S.cut = 1'b1;
                        S.word = 1'b1;
                    end
                endcase
            end
            7'd8: begin  // jsr
                case (phase)
                    3'd0: begin  // 28'h4a00282: mem, data, word, sp_dec, sp_asrt0, pc_asrtD
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.pc_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                    3'd1: begin  // 28'hc080980: mem, word, read, pc_asrt0, pc_latch
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.pc_latch = 1'b1;
                        S.pc_asrt0 = 1'b1;
                        S.mem = 1'b1;
                    end
                endcase
            end
            7'd9: begin  // rti
                case (phase)
                    3'd0: begin  // 28'h5280882: mem, data, word, read, sp_asrt0, pc_latch, sp_inc
                        S.word = 1'b1;
                        S.sp_inc = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.read = 1'b1;
                        S.pc_latch = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                    3'd1: begin  // 28'hd284082: mem, data, word, read, sp_asrt0, ps_latch_word, sp_inc
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_inc = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.read = 1'b1;
                        S.ps_latch_word = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd10: begin  // pupc
                case (phase)
                    3'd0: begin  // 28'hca00282: mem, data, word, sp_dec, sp_asrt0, pc_asrtD
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.pc_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd11: begin  // popc
                case (phase)
                    3'd0: begin  // 28'hd280882: mem, data, word, read, sp_asrt0, pc_latch, sp_inc
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_inc = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.read = 1'b1;
                        S.pc_latch = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd12: begin  // pusp
                case (phase)
                    3'd0: begin  // 28'hce00082: mem, data, word, sp_dec, sp_asrt0, sp_asrtD
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrtd = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd13: begin  // posp
                case (phase)
                    3'd0: begin  // 28'he280082: mem, data, word, read, sp_asrt0, sp_latch
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_latch = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.read = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd14: begin  // pups
                case (phase)
                    3'd0: begin  // 28'hca01082: mem, data, word, sp_dec, sp_asrt0, ps_asrtD
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.ps_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd15: begin  // pops
                case (phase)
                    3'd0: begin  // 28'hd284082: mem, data, word, read, sp_asrt0, ps_latch_word, sp_inc
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_inc = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.read = 1'b1;
                        S.ps_latch_word = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd16: begin  // push
                case (phase)
                    3'd0: begin  // 28'hca20082: mem, data, word, sp_dec, sp_asrt0, r_asrtD
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd17: begin  // pop
                case (phase)
                    3'd0: begin  // 28'hd2c0082: mem, data, word, read, sp_asrt0, r_latch, sp_inc
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_inc = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd18: begin  // ldi
                case (phase)
                    3'd0: begin  // 28'hc0c0580: mem, word, read, pc_asrt0, r_latch, pc_inc
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.pc_inc = 1'b1;
                        S.pc_asrt0 = 1'b1;
                        S.mem = 1'b1;
                    end
                endcase
            end
            7'd19: begin  // jsrr
                case (phase)
                    3'd0: begin  // 28'h4a00282: mem, data, word, sp_dec, sp_asrt0, pc_asrtD
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.pc_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                    3'd1: begin  // 28'h8020800: r_asrtD, pc_latch
                        S.cut = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.pc_latch = 1'b1;
                    end
                endcase
            end
            7'd20: begin  // ldsp
                case (phase)
                    3'd0: begin  // 28'h8440000: sp_asrtD, r_latch
                        S.cut = 1'b1;
                        S.sp_asrtd = 1'b1;
                        S.r_latch = 1'b1;
                    end
                endcase
            end
            7'd21: begin  // stsp
                case (phase)
                    3'd0: begin  // 28'ha020000: sp_latch, r_asrtD
                        S.cut = 1'b1;
                        S.sp_latch = 1'b1;
                        S.r_asrtd = 1'b1;
                    end
                endcase
            end
            7'd22: begin  // ldps
                case (phase)
                    3'd0: begin  // 28'h8041000: ps_asrtD, r_latch
                        S.cut = 1'b1;
                        S.r_latch = 1'b1;
                        S.ps_asrtd = 1'b1;
                    end
                endcase
            end
            7'd23: begin  // stps
                case (phase)
                    3'd0: begin  // 28'h8024000: ps_latch_word, r_asrtD
                        S.cut = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.ps_latch_word = 1'b1;
                    end
                endcase
            end
            7'd24: begin  // ldpc
                case (phase)
                    3'd0: begin  // 28'h8040200: pc_asrtD, r_latch
                        S.cut = 1'b1;
                        S.r_latch = 1'b1;
                        S.pc_asrtd = 1'b1;
                    end
                endcase
            end
            7'd25: begin  // stpc
                case (phase)
                    3'd0: begin  // 28'h8020800: pc_latch, r_asrtD
                        S.cut = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.pc_latch = 1'b1;
                    end
                endcase
            end
            7'd26: begin  // addsp
                case (phase)
                    3'd0: begin  // 28'ha210001: sp_asrt0, r_asrt1, alu_asrtD, sp_latch
                        S.cut = 1'b1;
                        S.sp_latch = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd32: begin  // move
                case (phase)
                    3'd0: begin  // 28'h804a001: r_asrt0, alu_asrtD, r_latch, ps_latch_flags
                        S.cut = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.ps_latch_flags = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd48: begin  // ldw_2
                case (phase)
                    3'd0: begin  // 28'hc0c8082: mem, data, read, word, r_asrt0, r_latch
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd49: begin  // ldb_2
                case (phase)
                    3'd0: begin  // 28'h80c8082: mem, data, read, r_asrt0, r_latch
                        S.cut = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd50: begin  // ldsb_2
                case (phase)
                    3'd0: begin  // 28'h81c8082: mem, data, read, sign_extend, r_asrt0, r_latch
                        S.cut = 1'b1;
                        S.sign_extend = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd51: begin  // ldcw_2
                case (phase)
                    3'd0: begin  // 28'hc0c8080: mem, read, word, r_asrt0, r_latch
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                    end
                endcase
            end
            7'd52: begin  // ldcb_2
                case (phase)
                    3'd0: begin  // 28'h80c8080: mem, read, r_asrt0, r_latch
                        S.cut = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                    end
                endcase
            end
            7'd53: begin  // ldcsb_2
                case (phase)
                    3'd0: begin  // 28'h81c8080: mem, read, sign_extend, r_asrt0, r_latch
                        S.cut = 1'b1;
                        S.sign_extend = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                    end
                endcase
            end
            7'd54: begin  // stw_2
                case (phase)
                    3'd0: begin  // 28'hc028082: mem, data, word, r_asrt0, r_asrtD
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd55: begin  // stb_2
                case (phase)
                    3'd0: begin  // 28'h8028082: mem, data, r_asrt0, r_asrtD
                        S.cut = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd64: begin  // lsw_p
                case (phase)
                    3'd0: begin  // 28'hc0c00ce: mem, data, read, word, fp_asrt0, imm_asrt1, imm_shift, r_latch
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.mem = 1'b1;
                        S.imm_shift = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.fp_asrt0 = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd65: begin  // lsw_n
                case (phase)
                    3'd0: begin  // 28'hc0c00ee: mem, data, read, word, fp_asrt0, imm_asrt1, imm_shift, r_latch, imm_extend_negative
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.mem = 1'b1;
                        S.imm_shift = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.fp_asrt0 = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd66: begin  // lsb_p
                case (phase)
                    3'd0: begin  // 28'h80c008e: mem, data, read, fp_asrt0, imm_asrt1, r_latch
                        S.cut = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.mem = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.fp_asrt0 = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd67: begin  // lsb_n
                case (phase)
                    3'd0: begin  // 28'h80c00ae: mem, data, read, fp_asrt0, imm_asrt1, r_latch, imm_extend_negative
                        S.cut = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.mem = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.fp_asrt0 = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd68: begin  // lssb_p
                case (phase)
                    3'd0: begin  // 28'h81c008e: mem, data, read, sign_extend, fp_asrt0, imm_asrt1, r_latch
                        S.cut = 1'b1;
                        S.sign_extend = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.mem = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.fp_asrt0 = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd69: begin  // lssb_n
                case (phase)
                    3'd0: begin  // 28'h81c00ae: mem, data, read, sign_extend, fp_asrt0, imm_asrt1, r_latch, imm_extend_negative
                        S.cut = 1'b1;
                        S.sign_extend = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.mem = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.fp_asrt0 = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd70: begin  // ssw_p
                case (phase)
                    3'd0: begin  // 28'hc0200ce: mem, data, word, fp_asrt0, imm_asrt1, imm_shift, r_asrtD
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.imm_shift = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.fp_asrt0 = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd71: begin  // ssw_n
                case (phase)
                    3'd0: begin  // 28'hc0200ee: mem, data, word, fp_asrt0, imm_asrt1, imm_shift, r_asrtD, imm_extend_negative
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.imm_shift = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.fp_asrt0 = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd72: begin  // ssb_p
                case (phase)
                    3'd0: begin  // 28'h802008e: mem, data, fp_asrt0, imm_asrt1, r_asrtD
                        S.cut = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.fp_asrt0 = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd73: begin  // ssb_n
                case (phase)
                    3'd0: begin  // 28'h80200ae: mem, data, fp_asrt0, imm_asrt1, r_asrtD, imm_extend_negative
                        S.cut = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.fp_asrt0 = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd74: begin  // ldi_p
                case (phase)
                    3'd0: begin  // 28'h8040010: r_latch, imm_asrtD
                        S.cut = 1'b1;
                        S.r_latch = 1'b1;
                        S.imm_asrtd = 1'b1;
                    end
                endcase
            end
            7'd75: begin  // ldi_n
                case (phase)
                    3'd0: begin  // 28'h8040030: r_latch, imm_asrtD, imm_extend_negative
                        S.cut = 1'b1;
                        S.r_latch = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrtd = 1'b1;
                    end
                endcase
            end
            7'd76: begin  // add_p
                case (phase)
                    3'd0: begin  // 28'h804a009: r_asrt0, imm_asrt1, alu_asrtD, r_latch, ps_latch_flags
                        S.cut = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.ps_latch_flags = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd77: begin  // add_n
                case (phase)
                    3'd0: begin  // 28'h804a029: r_asrt0, imm_asrt1, alu_asrtD, r_latch, ps_latch_flags, imm_extend_negative
                        S.cut = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.ps_latch_flags = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd78: begin  // cmp_p
                case (phase)
                    3'd0: begin  // 28'h800a008: r_asrt0, imm_asrt1, ps_latch_flags
                        S.cut = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.ps_latch_flags = 1'b1;
                        S.imm_asrt1 = 1'b1;
                    end
                endcase
            end
            7'd79: begin  // cmp_n
                case (phase)
                    3'd0: begin  // 28'h800a028: r_asrt0, imm_asrt1, ps_latch_flags, imm_extend_negative
                        S.cut = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.ps_latch_flags = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrt1 = 1'b1;
                    end
                endcase
            end
            7'd80: begin  // int
                case (phase)
                    3'd0: begin  // 28'h4a01082: mem, data, word, sp_asrt0, sp_dec, ps_asrtD
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.ps_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                    3'd1: begin  // 28'h4a00282: mem, data, word, sp_asrt0, sp_dec, pc_asrtD
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.pc_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                    3'd2: begin  // 28'h4080888: mem, read, word, imm_asrt1, pc_latch
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.pc_latch = 1'b1;
                        S.mem = 1'b1;
                        S.imm_asrt1 = 1'b1;
                    end
                    3'd3: begin  // 28'hc084088: mem, read, word, imm_asrt1, ps_latch_word
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.ps_latch_word = 1'b1;
                        S.mem = 1'b1;
                        S.imm_asrt1 = 1'b1;
                    end
                endcase
            end
            7'd81: begin  // reset: load PC/PS from vector
                case (phase)
                    3'd0: begin  // 28'h4080888: mem, read, word, imm_asrt1, pc_latch
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.pc_latch = 1'b1;
                        S.mem = 1'b1;
                        S.imm_asrt1 = 1'b1;
                    end
                    3'd1: begin  // 28'hc084088: mem, read, word, imm_asrt1, ps_latch_word
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.ps_latch_word = 1'b1;
                        S.mem = 1'b1;
                        S.imm_asrt1 = 1'b1;
                    end
                endcase
            end
            7'd82: begin  // push_p
                case (phase)
                    3'd0: begin  // 28'hca00092: mem, data, word, sp_dec, sp_asrt0, imm_asrtD
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.imm_asrtd = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd83: begin  // push_n
                case (phase)
                    3'd0: begin  // 28'hca000b2: mem, data, word, sp_dec, sp_asrt0, imm_asrtD, imm_extend_negative
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrtd = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd84: begin  // addsp_p
                case (phase)
                    3'd0: begin  // 28'ha200049: sp_asrt0, imm_asrt1, imm_shift, alu_asrtD, sp_latch
                        S.cut = 1'b1;
                        S.sp_latch = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.imm_shift = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd85: begin  // addsp_n
                case (phase)
                    3'd0: begin  // 28'ha200069: sp_asrt0, imm_asrt1, imm_shift, alu_asrtD, sp_latch, imm_extend_negative
                        S.cut = 1'b1;
                        S.sp_latch = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.imm_shift = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd86: begin  // jsr_rel_p
                case (phase)
                    3'd0: begin  // 28'h4a00282: mem, data, word, sp_dec, sp_asrt0, pc_asrtD
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.pc_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                    3'd1: begin  // 28'h8000949: pc_asrt0, imm_asrt1, imm_shift, alu_asrtD, pc_latch
                        S.cut = 1'b1;
                        S.pc_latch = 1'b1;
                        S.pc_asrt0 = 1'b1;
                        S.imm_shift = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd87: begin  // jsr_rel_n
                case (phase)
                    3'd0: begin  // 28'h4a00282: mem, data, word, sp_dec, sp_asrt0, pc_asrtD
                        S.word = 1'b1;
                        S.sp_dec = 1'b1;
                        S.sp_asrt0 = 1'b1;
                        S.pc_asrtd = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                    3'd1: begin  // 28'h8000969: pc_asrt0, imm_asrt1, imm_extend_negative, imm_shift, alu_asrtD, pc_latch
                        S.cut = 1'b1;
                        S.pc_latch = 1'b1;
                        S.pc_asrt0 = 1'b1;
                        S.imm_shift = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd96: begin  // ldw_3
                case (phase)
                    3'd0: begin  // 28'hc0d8082: mem, data, read, word, r_asrt0, r_asrt1, r_latch
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd97: begin  // ldb_3
                case (phase)
                    3'd0: begin  // 28'h80d8082: mem, data, read, r_asrt0, r_asrt1, r_latch
                        S.cut = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd98: begin  // ldsb_3
                case (phase)
                    3'd0: begin  // 28'h81d8082: mem, data, read, sign_extend, r_asrt0, r_asrt1, r_latch
                        S.cut = 1'b1;
                        S.sign_extend = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd99: begin  // ldcw_3
                case (phase)
                    3'd0: begin  // 28'hc0d8080: mem, read, word, r_asrt0, r_asrt1, r_latch
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                    end
                endcase
            end
            7'd100: begin  // ldcb_3
                case (phase)
                    3'd0: begin  // 28'h80d8080: mem, read, r_asrt0, r_asrt1, r_latch
                        S.cut = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                    end
                endcase
            end
            7'd101: begin  // ldcsb_3
                case (phase)
                    3'd0: begin  // 28'h81d8080: mem, read, sign_extend, r_asrt0, r_asrt1, r_latch
                        S.cut = 1'b1;
                        S.sign_extend = 1'b1;
                        S.read = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                    end
                endcase
            end
            7'd102: begin  // stw_3
                case (phase)
                    3'd0: begin  // 28'hc038082: mem, data, word, r_asrt0, r_asrt1, r_asrtD
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd103: begin  // stb_3
                case (phase)
                    3'd0: begin  // 28'h8038082: mem, data, r_asrt0, r_asrt1, r_asrtD
                        S.cut = 1'b1;
                        S.r_asrtd = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.mem = 1'b1;
                        S.data = 1'b1;
                    end
                endcase
            end
            7'd112: begin  // br_abs
                case (phase)
                    3'd0: begin  // 28'hc080980: mem, read, word, pc_asrt0, pc_latch
                        S.cut = 1'b1;
                        S.word = 1'b1;
                        S.read = 1'b1;
                        S.pc_latch = 1'b1;
                        S.pc_asrt0 = 1'b1;
                        S.mem = 1'b1;
                    end
                endcase
            end
            7'd113: begin  // shifts_alu2
                case (phase)
                    3'd0: begin  // 28'h804a001: r_asrt0, alu_asrtD, r_latch, ps_latch_flags
                        S.cut = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.ps_latch_flags = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd114: begin  // alu3_ind
                case (phase)
                    3'd0: begin  // 28'h801a000: r_asrt0, r_asrt1, ps_latch_flags
                        S.cut = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.ps_latch_flags = 1'b1;
                    end
                endcase
            end
            7'd115: begin  // alu3
                case (phase)
                    3'd0: begin  // 28'h805a001: r_asrt0, r_asrt1, alu_asrtD, r_latch, ps_latch_flags
                        S.cut = 1'b1;
                        S.r_latch = 1'b1;
                        S.r_asrt1 = 1'b1;
                        S.r_asrt0 = 1'b1;
                        S.ps_latch_flags = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd116: begin  // br_rel_p
                case (phase)
                    3'd0: begin  // 28'h8000949: pc_asrt0, imm_asrt1, imm_shift, alu_asrtD, pc_latch
                        S.cut = 1'b1;
                        S.pc_latch = 1'b1;
                        S.pc_asrt0 = 1'b1;
                        S.imm_shift = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd117: begin  // br_rel_n
                case (phase)
                    3'd0: begin  // 28'h8000969: pc_asrt0, imm_asrt1, imm_extend_negative, imm_shift, alu_asrtD, pc_latch
                        S.cut = 1'b1;
                        S.pc_latch = 1'b1;
                        S.pc_asrt0 = 1'b1;
                        S.imm_shift = 1'b1;
                        S.imm_extend_neg = 1'b1;
                        S.imm_asrt1 = 1'b1;
                        S.alu_asrtd = 1'b1;
                    end
                endcase
            end
            7'd118: begin  // br_abs_nop
                case (phase)
                    3'd0: begin  // 28'h8000400: pc_inc
                        S.cut = 1'b1;
                        S.pc_inc = 1'b1;
                    end
                endcase
            end
            7'd119: begin  // br_rel_nop
                case (phase)
                    3'd0: begin  // 28'hc000000: word
                        S.cut = 1'b1;
                        S.word = 1'b1;
                    end
                endcase
            end
        endcase
    end
endmodule
