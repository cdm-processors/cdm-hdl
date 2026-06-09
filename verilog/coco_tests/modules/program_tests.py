from pathlib import Path
import subprocess
import tempfile

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import yaml

# coco_tests/program_tests/resources/cdm16/{input,output}
RESOURCES_PATH = Path(__file__).resolve().parents[1] / "program_tests" / "resources" / "cdm16"

MAX_CYCLES = 200_000


def collect_testcases():
    return [
        (test, RESOURCES_PATH / "output" / test.with_suffix(".yaml").name)
        for test in (RESOURCES_PATH / "input").iterdir()
    ]


def compile_asm(asm_path: Path) -> bytes:
    with tempfile.TemporaryDirectory() as tmp_dir:
        out_path = Path(tmp_dir) / "out.bin"
        process = subprocess.run(
            ["cocas", "--target", "cdm16", "--output", out_path.as_posix(), asm_path.as_posix()],
            capture_output=True,
        )
        if process.returncode != 0:
            raise RuntimeError(f"Can't compile {asm_path.name}: {process.stderr}")
        cocotb.log.info(f"Compiled {asm_path.name}")
        return out_path.read_bytes()


def read_register(dut, name: str) -> int:
    """Map a .yaml register name to a value read from our core via hierarchy."""
    if name == "ps":
        return int(dut.ps.value)
    if name == "pc":
        return int(dut.pc.value)
    if name == "fp":
        return int(dut.u_reg_file.regFile[7].value)
    if name == "sp":
        return int(dut.sp.value)
    if name.startswith("r"):
        reg_num = int(name[1:])
        assert 0 <= reg_num <= 7, f"invalid register name: {name}"
        return int(dut.u_reg_file.regFile[reg_num].value)
    raise NotImplementedError(f"register '{name}' not handled yet")


testcases = collect_testcases()


@cocotb.test(timeout_time=2, timeout_unit="ms")
@cocotb.parametrize(case=testcases)
async def run_program(dut, case):
    asm_path, yaml_path = case
    bs = compile_asm(asm_path)
    expected = yaml.safe_load(yaml_path.read_bytes())

    cocotb.log.info(f"Running {asm_path.name}")

    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # load program (data comes from the testbench, not from RTL init)
    for i, b in enumerate(bs):
        dut.u_memory.mem[i].value = b

    dut.irq.value = 0
    dut.irq_vector.value = 0

    # reset
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # run until the core halts
    for _ in range(MAX_CYCLES):
        await RisingEdge(dut.clk)
        if int(dut.halted.value) == 1:
            break
    else:
        assert False, f"{asm_path.name}: core did not halt within {MAX_CYCLES} cycles"

    # check registers
    for name, ref in expected.get("registers", {}).items():
        actual = read_register(dut, name)
        cocotb.log.info(f"{name} = {actual:#06x}, expected {ref:#06x}")
        assert actual == ref, f"{asm_path.name}: {name} = {actual:#x}, expected {ref:#x}"

    # check memory (byte addresses, little-endian)
    for address, ref in expected.get("memory", {}).items():
        ref_len = (ref.bit_length() + 7) // 8
        low = int(dut.u_memory.mem[address].value)
        high = int(dut.u_memory.mem[address + 1].value)
        actual = (high << 8) + low
        if ref_len == 1:
            actual &= 0xFF
        cocotb.log.info(f"mem[{address:#06x}] = {actual:#06x}, expected {ref:#06x}")
        assert actual == ref, f"{asm_path.name}: mem[{address:#x}] = {actual:#x}, expected {ref:#x}"
