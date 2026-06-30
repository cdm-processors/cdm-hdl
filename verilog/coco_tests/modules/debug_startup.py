import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


def show(sig):
    try:
        return f"{int(sig.value):#06x}"
    except Exception:
        return str(sig.value)


@cocotb.test()
async def debug_startup(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    program = {
        0: 0x06, 1: 0x00,   # vector0 PC  = 0x0006
        2: 0x00, 3: 0x80,   # vector0 PS  = 0x8000
        6: 0x04, 7: 0x00,   # main: halt (0x0004)
    }
    for addr, byte in program.items():
        if addr & 1:
            dut.u_memory.bank1[addr >> 1].value = byte
        else:
            dut.u_memory.bank0[addr >> 1].value = byte

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    for cycle in range(10):
        await RisingEdge(dut.clk)
        dut._log.info(
            f"cyc{cycle} "
            f"fetch={show(dut.fetch_state)} "
            f"phase={show(dut.phase)} "
            f"instr={show(dut.instr_reg)} "
            f"is_reset={show(dut.is_reset)} "
            f"imm={show(dut.u_cpu_bus.imm)} "
            f"addr(alu)={show(dut.alu_result)} "
            f"mem_data={show(dut.mem_data)} "
            f"pc={show(dut.pc)} "
            f"ps={show(dut.ps)}"
        )
