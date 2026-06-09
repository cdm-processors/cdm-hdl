# CdM-16 HDL Implementation

Hardware implementation of the **CdM-16 educational processor** using **SystemVerilog**.

This project implements a hardware model of the **CdM-16 CPU architecture** and its main modules, intended for simulation and FPGA synthesis.  
The processor is designed as part of the *Digital Platforms* course and serves as a more advanced alternative to the CdM-8 educational processor.

The goal of this project is to build a working RTL implementation of the architecture, verify it against the reference model, and analyze its FPGA performance.

---

## Architecture Overview

**CdM-16** is a **16-bit educational RISC processor** designed for studying computer architecture and low-level programming.

Key features:

- **16-bit datapath and ALU**
- **64 KB address space**
- **8 general-purpose registers (r0–r7)**
- Special registers:
  - **PC** — program counter
  - **SP** — stack pointer
  - **PS** — processor status register
- Hardware **interrupts and exceptions**
- **Stack support**
- Multiple **addressing modes**
- **Little-endian memory model**

The architecture supports arithmetic operations, memory access instructions, control flow, stack operations, and interrupt handling.

---

## Project Goals

The project aims to:

- Implement a **hardware RTL model of CdM-16** (datapath + microcode control unit)
- Keep the code **clean and modular** — consistent signal naming, typed signals
  (`typedef`/`enum`, packed `ucode_word_t`), and a split, readable `core`
- **Verify** the implementation against the reference test suite (assembly programs
  with expected results)
- Explore **microcode-based control logic**
- Move memory from distributed **LUTs to Block RAM (BRAM)** to free logic and reach 64 KB
- Run the processor on **FPGA hardware** (Basys 3 / Vivado)

---

## Technologies

| Component | Tool |
|---|---|
| HDL | **SystemVerilog** |
| Simulator | **Icarus Verilog / Vivado 2019.2** |
| Test framework | **cocotb (Python)** |
| Assembler | **cocas** (`cdm-devkit`) |
| Reference | **Logisim model** + **cdm16-pipeline** test suite |

---

## Repository Structure

```text
verilog/
  rtl/
    core_base.svh              # constants, types, enums, packed ucode_word_t
    core/
      core.sv                  # top: module wiring + PS / SP / halt-wait blocks
      core_sequencer.sv        # fetch / exception sequencer (FSM)
      cpu_bus.sv               # ALU / data bus multiplexers
      memory.sv                # byte-addressable little-endian memory
    modules/
      alu.sv  branch.sv  decoder.sv  gen_ucode.sv
      imm_decoder.sv  pc_file.sv  reg_file.sv
    lib/
      rams_tdp_rf_rf.sv
  coco_tests/
    Makefile  reqs.txt
    modules/                   # cocotb tests: alu, decoder, gen_ucode,
                               #   imm_decoder, core, program_tests, debug_startup
    program_tests/resources/   # reference .asm + expected .yaml (from cdm16-pipeline)
  constr/
    basys_3.xdc
docs/                          # overview, learning notes, change log
```

---  
  
## CPU Microarchitecture  
  
The processor is organized as a classic **datapath + control unit** architecture.  
  
### Main Components  
  
- **ALU**  
Performs arithmetic and logical operations and updates flags (N, Z, V, C).  
  
- **Register File**  
Contains 8 general-purpose registers.  
  
- **Program Counter (PC)**  
Holds address of the next instruction.  
  
- **Control Unit**  
Decodes instructions and generates control signals.  
  
- **Memory Interface**  
Handles load/store operations and supports byte and word access.  
  
The processor follows a **fetch–execute cycle** and does not use instruction pipelining in the baseline implementation.  
  
---  
  
## Verification  
  
Testing is performed with **cocotb** on **Icarus Verilog**:  
  
- **Reference programs** (`.asm`) are assembled with **cocas** and run on the core;
  final registers and memory are compared against expected **`.yaml`** results
  (17 programs adopted from the **cdm16-pipeline** suite).
- **Per-module tests** for the ALU, decoder, microcode and immediate decoder.

Run from `verilog/coco_tests` (requires `iverilog`, `cocas`, and `pip install -r reqs.txt`):

```bash
make program_tests   # 17 reference programs on the whole core
make all_tests       # module tests + core_tests + program_tests
```

Current state: **all 17 reference programs and all module tests pass.**
  
---  
  
## FPGA Targets  
  
Planned FPGA synthesis and testing using:  
  
- **Xilinx Vivado**  
- Possible deployment on a development board for running simple programs (e.g. LED blinking demo).  
  
---  
  
## References  
  
- CdM-16 Architecture Overview  
https://github.com/cdm-processors/cdm-devkit  
  
- CdM-16 specification (course materials)   
  
---  
  
## Status  

- ✅ Datapath + microcode control unit implemented (non-pipelined fetch–execute core)
- ✅ Startup, internal exceptions and external interrupts (virtual-instruction entry)
- ✅ Byte-addressable little-endian memory with sign extension
- ✅ Verified: **17/17 reference programs** + all module tests pass
- ✅ Refactor: fetch/exception sequencer split into `core_sequencer.sv`
- 🚧 In progress: migration to **Block RAM** (synchronous read)
- ⏭️ Next: FPGA synthesis (Vivado / Basys 3), Fmax & resource metrics; double-fault policy
