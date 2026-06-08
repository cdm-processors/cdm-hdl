import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


async def tick(dut):
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")


@cocotb.test()
async def test_fetch_halt(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.u_memory.ram[0].value = 0x0004  # halt
    dut.u_memory.ram[1].value = 0x0004  # another halt

    dut.rst.value = 1
    await tick(dut)

    dut.rst.value = 0
    await tick(dut)  # fetch memory[0]

    assert int(dut.instr_reg.value) == 0x0004
    assert int(dut.instr_pc.value) == 0
    assert int(dut.pc.value) == 2
    assert int(dut.fetch_state.value) == 0

    await tick(dut)  # execute halt: cut -> fetch_state

    assert int(dut.fetch_state.value) == 1
    assert int(dut.pc.value) == 2

    await tick(dut)  # fetch memory[1]

    assert int(dut.instr_reg.value) == 0x0004
    assert int(dut.instr_pc.value) == 2
    assert int(dut.pc.value) == 4

@cocotb.test()
async def test_ldi_imm16_r0(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    dut.u_memory.ram[0].value = 0x2010
    dut.u_memory.ram[1].value = 0x1234
    dut.u_memory.ram[2].value = 0x0004  # halt after ldi

    dut.rst.value = 1
    await tick(dut)

    dut.rst.value = 0
    await tick(dut)  # fetch ldi

    assert int(dut.instr_reg.value) == 0x2010
    assert int(dut.instr_pc.value) == 0
    assert int(dut.pc.value) == 2

    await tick(dut)  # execute ldi

    assert int(dut.u_reg_file.regFile[0].value) == 0x1234
    assert int(dut.pc.value) == 4
    assert int(dut.fetch_state.value) == 1

    await tick(dut)  # fetch halt

    assert int(dut.instr_reg.value) == 0x0004
    assert int(dut.instr_pc.value) == 4
    assert int(dut.pc.value) == 6