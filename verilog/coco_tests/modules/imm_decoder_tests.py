import cocotb
from cocotb.triggers import Timer


async def check_imm(
    dut,
    *,
    imm6=0,
    imm9=0,
    phase=0,
    is_int=0,
    imm6_flag=0,
    imm_extend_neg=0,
    imm_shift=0,
    expected,
):
    dut.imm6.value = imm6
    dut.imm9.value = imm9
    dut.phase.value = phase
    dut.is_int.value = is_int
    dut.imm6_flag.value = imm6_flag
    dut.imm_extend_neg.value = imm_extend_neg
    dut.imm_shift.value = imm_shift

    await Timer(1, unit="ns")

    actual = int(dut.imm.value)
    assert actual == expected, (
        f"imm6=0x{imm6:02x} imm9=0x{imm9:03x} phase={phase} "
        f"is_int={is_int} imm6_flag={imm6_flag} "
        f"imm_extend_neg={imm_extend_neg} imm_shift={imm_shift}: "
        f"expected 0x{expected:04x}, got 0x{actual:04x}"
    )


@cocotb.test()
async def test_imm6_zero_extended(dut):
    await check_imm(
        dut,
        imm6=0b000101,
        imm6_flag=1,
        expected=0x0005,
    )


@cocotb.test()
async def test_imm6_sign_extended(dut):
    await check_imm(
        dut,
        imm6=0b111111,
        imm6_flag=1,
        imm_extend_neg=1,
        expected=0xffff,
    )


@cocotb.test()
async def test_imm9_zero_extended(dut):
    await check_imm(
        dut,
        imm9=0b1_0000_0000,
        expected=0x0100,
    )


@cocotb.test()
async def test_imm9_sign_extended(dut):
    await check_imm(
        dut,
        imm9=0b1_1111_1111,
        imm_extend_neg=1,
        expected=0xffff,
    )


@cocotb.test()
async def test_imm_shift(dut):
    await check_imm(
        dut,
        imm9=3,
        imm_shift=1,
        expected=0x0006,
    )


@cocotb.test()
async def test_int_vector_pc_word(dut):
    await check_imm(
        dut,
        imm9=5,
        phase=2,
        is_int=1,
        expected=0x0014,
    )


@cocotb.test()
async def test_int_vector_ps_word(dut):
    await check_imm(
        dut,
        imm9=5,
        phase=3,
        is_int=1,
        expected=0x0016,
    )


@cocotb.test()
async def test_int_unused_phase_is_zero(dut):
    await check_imm(
        dut,
        imm9=5,
        phase=0,
        is_int=1,
        expected=0x0000,
    )
