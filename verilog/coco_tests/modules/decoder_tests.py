import cocotb
from cocotb.triggers import Timer
import random
from .config import get_logger

logger = get_logger("decoder")
ITERATIONS = 20

UCODE_OP0 = 0
UCODE_OP1 = 1
UCODE_OP2 = 2
UCODE_MEM2 = 3
UCODE_IMM6 = 4
UCODE_IMM9 = 5
UCODE_MEM3 = 6
UCODE_DIRECT = 7

DIR_BR_ABS = 0
DIR_SHIFTS_ALU = 1
DIR_ALU3_IND = 2
DIR_ALU3 = 3
DIR_BR_REL_P = 4
DIR_BR_REL_N = 5
DIR_BR_ABS_NOP = 6
DIR_BR_REL_NOP = 7


def get_ucode(phase, sel, op):
    return (phase << 7) | (sel << 4) | op


async def verify_decoder(
    dut,
    instr,
    phase=0,
    cvzn=0,
    expected_rdi=None,
    expected_rsi0=None,
    expected_rsi1=None,
    expected_imm6=None,
    expected_imm9=None,
    expected_shamt=None,
    expected_is_branch=None,
    expected_ucode=None
):
    dut.instr.value = instr
    dut.phase.value = phase
    dut.CVZN.value = cvzn

    await Timer(1, unit="ns")

    errors = []
    def check(name, actual, expected):
        if expected is None:
            return
        if actual != expected:
            msg = f"{name} mismatch: actual={actual} expected={expected}"
            logger.error(msg)
            errors.append(msg)

    check("rdi", dut.rdi.value, expected_rdi)
    check("rsi0", dut.rsi0.value, expected_rsi0)
    check("rsi1", dut.rsi1.value, expected_rsi1)
    check("imm6", dut.imm6.value, expected_imm6)
    check("imm9", dut.imm9.value, expected_imm9)
    check("shamt", dut.shamt.value, expected_shamt)
    check("is_branch", dut.is_branch.value, expected_is_branch)
    check("ucode_addr", dut.ucode_addr.value, expected_ucode)
    
    if errors:
        logger.info("\n")
        raise AssertionError("\n".join(errors))

@cocotb.test()
async def test_0op(dut):
    for _ in range(ITERATIONS):
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
    for _ in range(ITERATIONS):
        alu_op = random.randint(0, 7)
        shift = random.randint(0, 7)
        rsi = random.randint(0, 7)
        rdi = random.randint(0, 7)
        instr = (1 << 12) | (alu_op << 9) | (shift << 6) | (rsi << 3) | rdi
        expected_u = get_ucode(0, UCODE_DIRECT, DIR_SHIFTS_ALU)
        await verify_decoder(dut, instr, expected_rsi0=rsi, expected_rdi=rdi, expected_shamt=shift, expected_is_branch=0, expected_ucode=expected_u)


@cocotb.test()
async def test_1op(dut):
    for _ in range(ITERATIONS):
        op_type = random.randint(0, 15)
        rdi = random.randint(0, 7)
        instr = (1 << 13) | (op_type << 3) | rdi
        expected_u = get_ucode(0, UCODE_OP1, op_type)
        await verify_decoder(dut, instr, expected_rdi=rdi, expected_is_branch=0, expected_ucode=expected_u)


@cocotb.test()
async def test_2op(dut):
    for _ in range(ITERATIONS):
        op_type = random.randint(0, 15)
        rsi = random.randint(0, 7)
        rdi = random.randint(0, 7)
        instr = (0b01000 << 11) | (op_type << 6) | (rsi << 3) | rdi
        expected_u = get_ucode(0, UCODE_OP2, op_type)
        await verify_decoder(dut, instr, expected_rsi0=rsi, expected_rdi=rdi, expected_is_branch=0, expected_ucode=expected_u)


@cocotb.test()
async def test_alu3_ind(dut):
    for _ in range(ITERATIONS):
        alu_op = random.randint(0, 7)
        rsi = random.randint(0, 7)
        rdi = random.randint(0, 7)
        instr = (0b01001 << 11) | (alu_op << 6) | (rsi << 3) | rdi
        expected_u = get_ucode(0, UCODE_DIRECT, DIR_ALU3_IND)
        await verify_decoder(dut, instr, expected_rsi0=rsi, expected_rdi=rdi, expected_is_branch=0, expected_ucode=expected_u)


@cocotb.test()
async def test_mem2(dut):
    for _ in range(ITERATIONS):
        op_type = random.randint(0, 15)
        rsi = random.randint(0, 7)
        rdi = random.randint(0, 7)
        instr = (0b01010 << 11) | (op_type << 6) | (rsi << 3) | rdi
        expected_u = get_ucode(0, UCODE_MEM2, op_type)
        await verify_decoder(dut, instr, expected_rsi0=rsi, expected_rdi=rdi, expected_is_branch=0, expected_ucode=expected_u)


@cocotb.test()
async def test_alu2(dut):
    for _ in range(ITERATIONS):
        alu_op = random.randint(0, 7)
        rsi = random.randint(0, 7)
        rdi = random.randint(0, 7)
        instr = (0b01011 << 11) | (alu_op << 6) | (rsi << 3) | rdi
        expected_u = get_ucode(0, UCODE_DIRECT, DIR_SHIFTS_ALU)
        await verify_decoder(dut, instr, expected_rsi0=rsi, expected_rdi=rdi, expected_is_branch=0, expected_ucode=expected_u)


@cocotb.test()
async def test_imm6(dut):
    for _ in range(ITERATIONS):
        op_type = random.randint(0, 15)
        imm = random.randint(0, 63)
        rdi = random.randint(0, 7)
        instr = (3 << 13) | (op_type << 9) | (imm << 3) | rdi
        expected_u = get_ucode(0, UCODE_IMM6, op_type)
        await verify_decoder(dut, instr, expected_imm6=imm, expected_rdi=rdi, expected_is_branch=0, expected_ucode=expected_u)


@cocotb.test()
async def test_imm9(dut):
    for _ in range(ITERATIONS):
        op_type = random.randint(0, 15)
        imm = random.randint(0, 511)
        instr = (4 << 13) | (op_type << 9) | imm
        expected_u = get_ucode(0, UCODE_IMM9, op_type)
        await verify_decoder(dut, instr, expected_imm9=imm, expected_is_branch=0, expected_ucode=expected_u)


@cocotb.test()
async def test_mem3(dut):
    for _ in range(ITERATIONS):
        op_type = random.randint(0, 7)
        rsi1 = random.randint(0, 7)
        rsi0 = random.randint(0, 7)
        rdi = random.randint(0, 7)
        instr = (0b1010 << 12) | (op_type << 9) | (
            rsi1 << 6) | (rsi0 << 3) | rdi
        expected_u = get_ucode(0, UCODE_MEM3, op_type)
        await verify_decoder(dut, instr, expected_rsi0=rsi0, expected_rsi1=rsi1, expected_rdi=rdi, expected_is_branch=0, expected_ucode=expected_u)


@cocotb.test()
async def test_alu3(dut):
    for _ in range(ITERATIONS):
        alu_op = random.randint(0, 7)
        rsi1 = random.randint(0, 7)
        rsi0 = random.randint(0, 7)
        rdi = random.randint(0, 7)
        instr = (0b1011 << 12) | (alu_op << 9) | (
            rsi1 << 6) | (rsi0 << 3) | rdi
        expected_u = get_ucode(0, UCODE_DIRECT, DIR_ALU3)
        await verify_decoder(dut, instr, expected_rsi0=rsi0, expected_rsi1=rsi1, expected_rdi=rdi, expected_is_branch=0, expected_ucode=expected_u)


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
