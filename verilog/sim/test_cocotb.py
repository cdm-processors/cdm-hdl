# cocotb-тест
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_rf_read_write(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())