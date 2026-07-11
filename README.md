# JTAG & BIST SoC Testing Infrastructure

## Overview
This repository contains a comprehensive Register-Transfer Level (RTL) implementation of the **IEEE 1149.1 JTAG** standard and a **Built-In Self-Test (BIST)** architecture, developed entirely in **VHDL**. 

Designed with a strong focus on Design for Testability (DFT) and Design Verification (DV), this project demonstrates the complete testing lifecycle of a custom Combinational Circuit Under Test (CUT). The architecture successfully isolates the internal logic from external physical pins, allowing for extensive controllability and observability through external test vectors and pseudo-random pattern generation.

## Key Features & Project Phases

### Phase 1: Scan Chain & Controllability (TRCUT)
*   **Multiplexed D-Flip Flops (SDFF):** Implementation of custom SDFFs to allow seamless switching between Normal/Capture Mode and Shift Mode.
*   **Overlapped Scan Optimization:** The testbench incorporates a pipelined testing logic. By overlapping the `Shift-In` of the next vector with the `Shift-Out` of the current response, the test time was significantly optimized, requiring only 5 clock cycles per vector (1 Capture + 4 simultaneous In/Out shifts).

### Phase 2: Built-In Self-Test (BIST) Subsystem
*   **Pseudo-Random Pattern Generation:** Integration of an 8-bit Linear Feedback Shift Register (LFSR) utilizing the primitive polynomial $P(x) = x^8 + x^4 + x^3 + x^2 + 1$ to generate on-chip test vectors.
*   **Signature Analysis:** A 16-bit Multiple Input Shift Register (MISR) based on Galois architecture is used for efficient output compaction and signature extraction.
*   **Fault Injection & Detection:** The testing infrastructure was successfully verified by injecting a permanent `stuck-at-1` fault into the CUT's logic. The MISR successfully caught the discrepancy, yielding a faulty signature (`3E81`) compared to the golden signature (`7532`).

### Phase 3: JTAG Building Blocks & TAP Controller
*   **TAP Controller:** A fully synchronous 16-state Finite State Machine (FSM) that orchestrates all testing operations based on the `TMS` and `TCK` signals, featuring an asynchronous `TRST` and a standard 5-clock emergency reset sequence to the `Test-Logic-Reset` state.
*   **Boundary Scan Cells (BSC):** Robust cells wrapping the CUT, utilizing independent Shift and Latch/Update registers to ensure stable output values during the serial data shift phase.
*   **Instruction Register (IR) & Bypass Register (BR):** A 2-bit pipelined IR for instruction decoding, and a 1-bit BR for minimum-delay path routing.

### Phase 4: Top-Level SoC Integration
*   **System Assembly:** Complete integration of the CUT with the Boundary Scan Register (BSR), IR, BR, and the TAP Controller.
*   **JTAG Instruction Execution:** The testbench verifies the proper execution of standard testing instructions:
    *   `SAMPLE/PRELOAD` (`01`): Transparent operation and signal sampling.
    *   `INTEST` (`10`): Internal logic testing via BSR isolation.
    *   `BYPASS` (`11`): Minimum-delay bypass path routing.

## Repository Structure

```text
├── docs/                   # Detailed technical documentation and reports
├── rtl/                    # VHDL Source Code (Design)
│   ├── CUT.vhd             # Circuit Under Test (Combinational Logic)
│   ├── MyDFF.vhd           # Basic D-Flip Flop primitive
│   ├── SDFF.vhd            # Scan D-Flip Flop (Multiplexed DFF)
│   ├── bsc.vhd             # Boundary Scan Cell
│   ├── BR.vhd              # Bypass Register
│   ├── IR.vhd              # Instruction Register Cell
│   ├── LFSR8_Internal.vhd  # 8-bit PRPG
│   ├── MISR16.vhd          # 16-bit Signature Analyzer
│   ├── tap_controller.vhd  # 16-state FSM TAP Controller
│   └── JTAG_Chip_Top.vhd   # Top-level SoC module integrating all IPs
│
├── tb/                     # VHDL Testbenches (Verification)
│   ├── TRCUT_tb.vhd        # BIST overlapping scan verification
│   ├── tb_bsc.vhd          # BSC individual block testing
│   ├── tb_tap_controller.vhd # FSM path coverage testing
│   └── JTAG_tb.vhd         # Top-level full JTAG protocol simulation
│
└── sim/                    # Simulation waveforms (ModelSim)
## Tools & Technologies
Hardware Description Language: VHDL-2008

Simulation & Verification: Siemens EDA ModelSim / Questa

Synthesis & RTL Viewing: Intel Quartus Prime

Methodologies: DFT, BIST, JTAG (IEEE 1149.1), FSM Design, Fault Injection

## Author
Athanasios Fytilis (5381)

Computer Science & Computer Engineering
