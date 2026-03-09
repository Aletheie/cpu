# 16-bit CPU in Logisim

Custom educational 16-bit CPU design implemented in Logisim, including ALU, control flow, memory/I/O instructions, and a demo program.

## Overview

- 16-bit data path
- 32-bit instruction format
- General-purpose registers `R1–R6`
- ALU operations, memory access, branching, and I/O instructions
- Demo program for testing functionality

## Architecture

### ALU

![ALU](alu.png)

### CPU

![CPU](cpu.png)

### ALU Components

![ALU Components](alu_components.png)

### Machine Code

![Machine Code](machine_code.png)

## Game Demo

- [Watch / download demo video](video.mp4)

https://github.com/user-attachments/assets/b5a13d79-0106-4332-a82c-5b3f83250787

## Project Files

- [Detailed CPU documentation](dokumentace.md)
- [Program listing / machine code output](program.txt)
- [Machine code spreadsheet](strojovy_kod.xlsx)
- `ALU.circ` – ALU circuit
- `CPU.circ` – CPU top-level circuit
- `program.asm` – assembly source

## How to Use

1. Open `CPU.circ` in Logisim.
2. Load program data into ROM (from your assembled output).
3. Run simulation and observe register/memory/I/O behavior.
