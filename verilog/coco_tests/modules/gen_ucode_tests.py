import cocotb
from cocotb.triggers import Timer

from .config import get_logger

logger = get_logger("gen_ucode")


def uaddr(phase, rule):
    assert 0 <= phase < 8
    assert 0 <= rule < 128
    return (phase << 7) | rule


GOLDEN_UCODE = {
    uaddr(0, 4): 0xC000000,  # halt
    uaddr(0, 5): 0xC000000,  # wait
    uaddr(0, 6): 0xC000000,  # ei
    uaddr(0, 7): 0xC000000,  # di
    uaddr(0, 8): 0x4A00282,  # jsr
    uaddr(1, 8): 0xC080980,  # jsr
    uaddr(0, 9): 0x5280882,  # rti
    uaddr(1, 9): 0xD284082,  # rti
    uaddr(0, 10): 0xCA00282,  # pupc
    uaddr(0, 11): 0xD280882,  # popc
    uaddr(0, 12): 0xCE00082,  # pusp
    uaddr(0, 13): 0xE280082,  # posp
    uaddr(0, 14): 0xCA01082,  # pups
    uaddr(0, 15): 0xD284082,  # pops
    uaddr(0, 16): 0xCA20082,  # push
    uaddr(0, 17): 0xD2C0082,  # pop
    uaddr(0, 18): 0xC0C0580,  # ldi
    uaddr(0, 19): 0x4A00282,  # jsrr
    uaddr(1, 19): 0x8020800,  # jsrr
    uaddr(0, 20): 0x8440000,  # ldsp
    uaddr(0, 21): 0xA020000,  # stsp
    uaddr(0, 22): 0x8041000,  # ldps
    uaddr(0, 23): 0x8024000,  # stps
    uaddr(0, 24): 0x8040200,  # ldpc
    uaddr(0, 25): 0x8020800,  # stpc
    uaddr(0, 26): 0xA210001,  # addsp
    uaddr(0, 32): 0x804A001,  # move
    uaddr(0, 48): 0xC0C8082,  # ldw_2
    uaddr(0, 49): 0x80C8082,  # ldb_2
    uaddr(0, 50): 0x81C8082,  # ldsb_2
    uaddr(0, 51): 0xC0C8080,  # ldcw_2
    uaddr(0, 52): 0x80C8080,  # ldcb_2
    uaddr(0, 53): 0x81C8080,  # ldcsb_2
    uaddr(0, 54): 0xC028082,  # stw_2
    uaddr(0, 55): 0x8028082,  # stb_2
    uaddr(0, 64): 0xC0C00CE,  # lsw_p
    uaddr(0, 65): 0xC0C00EE,  # lsw_n
    uaddr(0, 66): 0x80C008E,  # lsb_p
    uaddr(0, 67): 0x80C00AE,  # lsb_n
    uaddr(0, 68): 0x81C008E,  # lssb_p
    uaddr(0, 69): 0x81C00AE,  # lssb_n
    uaddr(0, 70): 0xC0200CE,  # ssw_p
    uaddr(0, 71): 0xC0200EE,  # ssw_n
    uaddr(0, 72): 0x802008E,  # ssb_p
    uaddr(0, 73): 0x80200AE,  # ssb_n
    uaddr(0, 74): 0x8040010,  # ldi_p
    uaddr(0, 75): 0x8040030,  # ldi_n
    uaddr(0, 76): 0x804A009,  # add_p
    uaddr(0, 77): 0x804A029,  # add_n
    uaddr(0, 78): 0x800A008,  # cmp_p
    uaddr(0, 79): 0x800A028,  # cmp_n
    uaddr(0, 80): 0x4A01082,  # int
    uaddr(1, 80): 0x4A00282,  # int
    uaddr(2, 80): 0x4080888,  # int
    uaddr(3, 80): 0xC084088,  # int
    uaddr(0, 81): 0x4080888,  # reset
    uaddr(1, 81): 0xC084088,  # reset
    uaddr(0, 82): 0xCA00092,  # push_p
    uaddr(0, 83): 0xCA000B2,  # push_n
    uaddr(0, 84): 0xA200049,  # addsp_p
    uaddr(0, 85): 0xA200069,  # addsp_n
    uaddr(0, 86): 0x4A00282,  # jsr_rel_p
    uaddr(1, 86): 0x8000949,  # jsr_rel_p
    uaddr(0, 87): 0x4A00282,  # jsr_rel_n
    uaddr(1, 87): 0x8000969,  # jsr_rel_n
    uaddr(0, 96): 0xC0D8082,  # ldw_3
    uaddr(0, 97): 0x80D8082,  # ldb_3
    uaddr(0, 98): 0x81D8082,  # ldsb_3
    uaddr(0, 99): 0xC0D8080,  # ldcw_3
    uaddr(0, 100): 0x80D8080,  # ldcb_3
    uaddr(0, 101): 0x81D8080,  # ldcsb_3
    uaddr(0, 102): 0xC038082,  # stw_3
    uaddr(0, 103): 0x8038082,  # stb_3
    uaddr(0, 112): 0xC080980,  # br_abs
    uaddr(0, 113): 0x804A001,  # shifts_alu2
    uaddr(0, 114): 0x801A000,  # alu3_ind
    uaddr(0, 115): 0x805A001,  # alu3
    uaddr(0, 116): 0x8000949,  # br_rel_p
    uaddr(0, 117): 0x8000969,  # br_rel_n
    uaddr(0, 118): 0x8000400,  # br_abs_nop
    uaddr(0, 119): 0xC000000,  # br_rel_nop
}


async def check_ucode(dut, addr, expected):
    dut.addr.value = addr
    await Timer(1, unit="ns")

    actual = int(dut.S.value)
    assert actual == expected, (f"addr={addr}: expected 0x{expected:07x}, got 0x{actual:07x}")


@cocotb.test()
async def test_halt(dut):
    await check_ucode(dut, uaddr(0, 4), 0xC000000)


@cocotb.test()
async def test_golden_ucode_table(dut):
    for addr in range(1024):
        expected = GOLDEN_UCODE.get(addr, 0)
        await check_ucode(dut, addr, expected)
