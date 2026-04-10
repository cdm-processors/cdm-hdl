import cocotb
from cocotb.triggers import Timer
import random

ITERATIONS = 1000

async def check(dut, op_type, func, A, B=0, carry=0, shift=0, expected=0):
    dut.op_type.value = op_type
    dut.func.value = func
    dut.A.value = A
    dut.B.value = B
    dut.carry_in.value = carry
    dut.shamt.value = shift

    await Timer(1, unit="ns")
    try:
        assert dut.R.value == (expected & 0xFFFF)
    except Exception as err:
        print(dut.A.value)
        print(dut.B.value)
        print(dut.carry_in.value)
        print(dut.R.value)
        
        print(dut.A.value.to_signed())
        print(dut.B.value.to_signed())
        print(dut.R.value.to_signed())
        print(expected)
        
        print(A, B, shift, op_type, func)
        raise

@cocotb.test()
async def alu_basic_test(dut):
    for _ in range(ITERATIONS):
        A = random.randint(0, 0xFFFF)
        B = random.randint(0, 0xFFFF)

        await check(dut, 0b001, 0, A, B, expected=(A & B))
        await check(dut, 0b001, 1, A, B, expected=(A | B))
        await check(dut, 0b001, 2, A, B, expected=(A ^ B))
        await check(dut, 0b001, 3, A, B, expected=(A & (~B)))

        await check(dut, 0b001, 4, A, B, expected=(A + B))
        await check(dut, 0b001, 5, A, B, carry=1, expected=(A + B + 1))

        await check(dut, 0b001, 6, A, B, expected=(A - B))
        await check(dut, 0b001, 7, A, B, carry=1, expected=(A - B))

        await check(dut, 0b010, 0, A, expected=(-A))
        await check(dut, 0b010, 1, A, expected=(~A))
        await check(dut, 0b010, 2, A, expected=((A & 0xFF) | (0xFF00 if A & 0x80 else 0)))
        await check(dut, 0b010, 3, A, expected=(A & 0xFF))


@cocotb.test()
async def alu_shift_test(dut):
    for _ in range(ITERATIONS):
        A = random.randint(0, 0xFFFF)
        shift = random.randint(0, 7)
        sc = shift + 1

        await check(dut, 0b100, 0, A, shift=shift, expected=(A << sc))
        await check(dut, 0b100, 1, A, shift=shift, expected=(A >> sc))

        if A & 0x8000:
            signed = A - 0x10000
        else:
            signed = A

        await check(dut, 0b100, 2, A, shift=shift, expected=(signed >> sc))

        await check(
            dut,
            0b100,
            3,
            A,
            shift=shift,
            expected=((A << sc) | (A >> (16 - sc)))
        )

        await check(
            dut,
            0b100,
            4,
            A,
            shift=shift,
            expected=((A >> sc) | (A << (16 - sc)))
        )
