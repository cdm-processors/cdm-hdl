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

- Implement a **hardware RTL model of CdM-16**
- Recreate the architecture described in the reference documentation
- Verify the implementation against the **Logisim reference model**
- Explore **microcode-based control logic**
- Run the processor on **FPGA hardware**

---

## Technologies

| Component | Tool |
|---|---|
| HDL | **SystemVerilog** |
| Simulator | **Icarus Verilog / Vivado 2019.2** |
| Test framework | **Cocotb (Python)** |
| Reference model | **Logisim implementation** |

---

## Repository Structure

```bash
│   .gitignore
│   README.md
│
├───lib
│       pf.sv
│
├───prg
│
└───src
    ├───constr
    │       rv_nsu_basys_3.sdc
    │       rv_nsu_basys_3.xdc
    │
    ├───rtl
    │       alu.sv
    │       register_file.sv
    │
    └───sim
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
  
Testing is performed using:  
  
- **Assembly test programs**  
- **Cocotb testbench**  
- Comparison with **logisim-runner execution logs**  
  
The processor should pass all ISA correctness tests before FPGA synthesis.  
  
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
  
🚧 **Work in progress**  
