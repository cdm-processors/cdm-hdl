import cocotb
from cocotb.triggers import Timer
import random

UCODE_OP0    = 0
UCODE_OP1    = 1
UCODE_OP2    = 2
UCODE_MEM2   = 3
UCODE_IMM6   = 4
UCODE_IMM9   = 5
UCODE_MEM3   = 6
UCODE_DIRECT = 7

DIR_BR_ABS     = 0
DIR_SHIFTS_ALU = 1
DIR_ALU3_IND   = 2
DIR_ALU3       = 3
DIR_BR_REL_P   = 4
DIR_BR_REL_N   = 5
DIR_BR_ABS_NOP = 6
DIR_BR_REL_NOP = 7

def get_ucode(phase, sel, op):
    return (phase << 7) | (sel << 4) | op

async def verify_decoder(dut, instr, phase=0, cvzn=0, expected_rd=None, expected_rs0=None, expected_rs1=None, expected_imm6=None, expected_imm9=None, expected_shamt=None, expected_is_branch=None, expected_ucode=None):
    dut.instr.value = instr
    dut.phase.value = phase
    dut.CVZN.value = cvzn
    
    await Timer(1, unit="ns")

    if expected_rd is not None:
        assert dut.rd.value == expected_rd
    if expected_rs0 is not None:
        assert dut.rs0.value == expected_rs0
    if expected_rs1 is not None:
        assert dut.rs1.value == expected_rs1
    if expected_imm6 is not None:
        assert dut.imm6.value == expected_imm6
    if expected_imm9 is not None:
        assert dut.imm9.value == expected_imm9
    if expected_shamt is not None:
        assert dut.shamt.value == expected_shamt
    if expected_is_branch is not None:
        assert dut.is_branch.value == expected_is_branch
    if expected_ucode is not None:
        assert dut.ucode_addr.value == expected_ucode

@cocotb.test()
async def test_0op(dut):
    for _ in range(4):
        op = random.randint(0, 15)
        instr = (0b00000 << 11) | op
        expected_u = get_ucode(0, UCODE_OP0, op)
        await verify_decoder(dut, instr, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_br_abs(dut):
    instr_go = (0b00001 << 11) | 14
    expected_u_go = get_ucode(0, UCODE_DIRECT, DIR_BR_ABS)
    await verify_decoder(dut, instr_go, expected_is_branch=1, expected_ucode=expected_u_go)

    instr_nop = (0b00001 << 11) | 15
    expected_u_nop = get_ucode(0, UCODE_DIRECT, DIR_BR_ABS_NOP)
    await verify_decoder(dut, instr_nop, expected_is_branch=1, expected_ucode=expected_u_nop)

@cocotb.test()
async def test_shifts(dut):
    for _ in range(4):
        alu_op = random.randint(0, 7)
        shift = random.randint(0, 7)
        rs = random.randint(0, 7)
        rd = random.randint(0, 7)
        instr = (1 << 12) | (alu_op << 9) | (shift << 6) | (rs << 3) | rd
        expected_u = get_ucode(0, UCODE_DIRECT, DIR_SHIFTS_ALU)
        await verify_decoder(dut, instr, expected_rs0=rs, expected_rd=rd, expected_shamt=shift, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_1op(dut):
    for _ in range(4):
        op_type = random.randint(0, 15)
        rd = random.randint(0, 7)
        instr = (1 << 13) | (op_type << 3) | rd
        expected_u = get_ucode(0, UCODE_OP1, op_type)
        await verify_decoder(dut, instr, expected_rd=rd, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_2op(dut):
    for _ in range(4):
        op_type = random.randint(0, 15)
        rs = random.randint(0, 7)
        rd = random.randint(0, 7)
        instr = (0b01000 << 11) | (op_type << 6) | (rs << 3) | rd
        expected_u = get_ucode(0, UCODE_OP2, op_type)
        await verify_decoder(dut, instr, expected_rs0=rs, expected_rd=rd, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_alu3_ind(dut):
    for _ in range(4):
        alu_op = random.randint(0, 7)
        rs = random.randint(0, 7)
        rd = random.randint(0, 7)
        instr = (0b01001 << 11) | (alu_op << 6) | (rs << 3) | rd
        expected_u = get_ucode(0, UCODE_DIRECT, DIR_ALU3_IND)
        await verify_decoder(dut, instr, expected_rs0=rs, expected_rd=rd, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_mem2(dut):
    for _ in range(4):
        op_type = random.randint(0, 15)
        rs = random.randint(0, 7)
        rd = random.randint(0, 7)
        instr = (0b01010 << 11) | (op_type << 6) | (rs << 3) | rd
        expected_u = get_ucode(0, UCODE_MEM2, op_type)
        await verify_decoder(dut, instr, expected_rs0=rs, expected_rd=rd, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_alu2(dut):
    for _ in range(4):
        alu_op = random.randint(0, 7)
        rs = random.randint(0, 7)
        rd = random.randint(0, 7)
        instr = (0b01011 << 11) | (alu_op << 6) | (rs << 3) | rd
        expected_u = get_ucode(0, UCODE_DIRECT, DIR_SHIFTS_ALU)
        await verify_decoder(dut, instr, expected_rs0=rs, expected_rd=rd, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_imm6(dut):
    for _ in range(4):
        op_type = random.randint(0, 15)
        imm = random.randint(0, 63)
        rd = random.randint(0, 7)
        instr = (3 << 13) | (op_type << 9) | (imm << 3) | rd
        expected_u = get_ucode(0, UCODE_IMM6, op_type)
        await verify_decoder(dut, instr, expected_imm6=imm, expected_rd=rd, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_imm9(dut):
    for _ in range(4):
        op_type = random.randint(0, 15)
        imm = random.randint(0, 511)
        instr = (4 << 13) | (op_type << 9) | imm
        expected_u = get_ucode(0, UCODE_IMM9, op_type)
        await verify_decoder(dut, instr, expected_imm9=imm, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_mem3(dut):
    for _ in range(4):
        op_type = random.randint(0, 7)
        rs1 = random.randint(0, 7)
        rs0 = random.randint(0, 7)
        rd = random.randint(0, 7)
        instr = (0b1010 << 12) | (op_type << 9) | (rs1 << 6) | (rs0 << 3) | rd
        expected_u = get_ucode(0, UCODE_MEM3, op_type)
        await verify_decoder(dut, instr, expected_rs0=rs0, expected_rs1=rs1, expected_rd=rd, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_alu3(dut):
    for _ in range(4):
        alu_op = random.randint(0, 7)
        rs1 = random.randint(0, 7)
        rs0 = random.randint(0, 7)
        rd = random.randint(0, 7)
        instr = (0b1011 << 12) | (alu_op << 9) | (rs1 << 6) | (rs0 << 3) | rd
        expected_u = get_ucode(0, UCODE_DIRECT, DIR_ALU3)
        await verify_decoder(dut, instr, expected_rs0=rs0, expected_rs1=rs1, expected_rd=rd, expected_is_branch=0, expected_ucode=expected_u)

@cocotb.test()
async def test_br_rel_n(dut):
    imm = random.randint(0, 511)
    
    instr_go = (6 << 13) | (14 << 9) | imm
    expected_u_go = get_ucode(0, UCODE_DIRECT, DIR_BR_REL_N)
    await verify_decoder(dut, instr_go, expected_imm9=imm, expected_is_branch=1, expected_ucode=expected_u_go)

    instr_nop = (6 << 13) | (15 << 9) | imm
    expected_u_nop = get_ucode(0, UCODE_DIRECT, DIR_BR_REL_NOP)
    await verify_decoder(dut, instr_nop, expected_imm9=imm, expected_is_branch=1, expected_ucode=expected_u_nop)

@cocotb.test()
async def test_br_rel_p(dut):
    imm = random.randint(0, 511)
    
    instr_go = (7 << 13) | (14 << 9) | imm
    expected_u_go = get_ucode(0, UCODE_DIRECT, DIR_BR_REL_P)
    await verify_decoder(dut, instr_go, expected_imm9=imm, expected_is_branch=1, expected_ucode=expected_u_go)

    instr_nop = (7 << 13) | (15 << 9) | imm
    expected_u_nop = get_ucode(0, UCODE_DIRECT, DIR_BR_REL_NOP)
    await verify_decoder(dut, instr_nop, expected_imm9=imm, expected_is_branch=1, expected_ucode=expected_u_nop)