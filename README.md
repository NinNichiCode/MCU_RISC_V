RISC-V 32-bit Microcontroller (SoC) on FPGA
+ Overview

This project implements a 32-bit RISC-V (RV32I) microcontroller fully designed from scratch in Verilog HDL, integrated into a complete System-on-Chip (SoC), and deployed on a Sipeed Tang Nano 9K FPGA.
The goal is to build a fully functional custom RISC-V SoC including CPU, memory, peripherals (GPIO, UART), and a software toolchain (C → firmware.hex).

+ Technologies

Languages & ISA: Verilog HDL, RISC-V RV32I, C

Tools: Gowin EDA, Icarus Verilog, GTKWave, RISC-V GCC Toolchain

Hardware: Sipeed Tang Nano 9K FPGA

+ Main Components

CPU Core

Multi-cycle FSM design

Supports the full RV32I base instruction set

Includes a 32×32-bit register file and ALU for arithmetic, logic, shift, and comparison

Memory (progmem.v)

4KB synchronous RAM (1024 × 32-bit words)

Byte-enable support for load/store

Firmware preloaded from firmware.hex

SoC Integration

Von Neumann architecture (shared instruction/data memory)

Unified bus connecting CPU, memory, and peripherals

Peripherals (MMIO)

LED GPIO: simple 32-bit register driving LEDs

UART TX/RX: serial communication via memory-mapped registers

+ Software Workflow

Programs written in C or Assembly

Compiled with RISC-V GCC Toolchain

ELF → binary → firmware.hex using custom Makefile & scripts

Firmware loaded into FPGA memory for execution

+ Verification & Testing

Simulation: Icarus Verilog + GTKWave

Assembly/C programs tested (arithmetic ops, branches, load/store, GPIO control)

FPGA Deployment: Verified real hardware functionality with LED blinking and UART echo program




Results

The project successfully demonstrates a custom 32-bit RISC-V microcontroller SoC, simulated and deployed on FPGA. The CPU core and peripherals operate correctly, proving the feasibility of building a full SoC from scratch in Verilog.
