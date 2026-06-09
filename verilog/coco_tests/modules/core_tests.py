import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

MAX_CYCLES = 1000


async def boot_and_run(dut, program: dict):
    """Load program bytes, drive inputs, reset, run until the core halts."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.irq.value = 0
    dut.irq_vector.value = 0

    for addr, byte in program.items():
        dut.u_memory.mem[addr].value = byte

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    for _ in range(MAX_CYCLES):
        await RisingEdge(dut.clk)
        if int(dut.halted.value) == 1:
            return
    assert False, "core did not halt"


@cocotb.test()
async def test_fetch_halt(dut):
    # startup vector: PC = 0x0004, PS = 0x0000 ; code at 0x0004: halt (0x0004)
    await boot_and_run(dut, {
        0x00: 0x04, 0x01: 0x00,
        0x02: 0x00, 0x03: 0x00,
        0x04: 0x04, 0x05: 0x00,
    })
    assert int(dut.halted.value) == 1


@cocotb.test()
async def test_ldi_imm16_r0(dut):
    # startup vector -> 0x0004 ; ldi r0, 0x1234 (0x2010 + imm word) ; halt
    await boot_and_run(dut, {
        0x00: 0x04, 0x01: 0x00,   # start PC = 0x0004
        0x02: 0x00, 0x03: 0x00,   # start PS = 0x0000
        0x04: 0x10, 0x05: 0x20,   # ldi r0, imm16  (opcode 0x2010)
        0x06: 0x34, 0x07: 0x12,   # immediate 0x1234
        0x08: 0x04, 0x09: 0x00,   # halt
    })
    assert int(dut.u_reg_file.regFile[0].value) == 0x1234
