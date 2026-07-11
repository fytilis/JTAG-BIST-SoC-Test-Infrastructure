# JTAG & BIST SoC Testing Infrastructure

## Overview
This repository contains a comprehensive Register-Transfer Level (RTL) implementation of the **IEEE 1149.1 JTAG** standard and a **Built-In Self-Test (BIST)** architecture, developed entirely in **VHDL**. 

Designed with a strong focus on Design for Testability (DFT) and Design Verification (DV), this project demonstrates the complete testing lifecycle of a custom Combinational Circuit Under Test (CUT). The architecture successfully isolates the internal logic from external physical pins, allowing for extensive controllability and observability through external test vectors and pseudo-random pattern generation.

## Key Features & Project Phases

### Phase 1: Scan Chain & Controllability (TRCUT)
*   **Multiplexed D-Flip Flops (SDFF):** Implementation of custom SDFFs to allow seamless switching between Normal/Capture Mode and Shift Mode.
*   **Overlapped Scan Optimization:** The testbench incorporates a pipelined testing logic. By overlapping the `Shift-In` of the next vector with the `Shift-Out` of the current response, the test time was significantly optimized, requiring only 5 clock cycles per vector (1 Capture + 4 simultaneous In/Out shifts).

### Phase 2: Built-In Self-Test (BIST) Subsystem
*   **Pseudo-Random Pattern Generation:** Integration of an 8-bit Linear Feedback Shift Register (LFSR) utilizing the primitive polynomial P(x) = x^8 + x^4 + x^3 + x^2 + 1 to generate on-chip test vectors.
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

---

## Repository Structure (Component-Based)

```text
JTAG-BIST-SoC-Test-Infrastructure/
│
├── 01_Scan_Chain_TRCUT/
│   ├── Report_1_Scan_Chain.pdf
│   ├── src/                 # RTL source files (CUT, MyDFF, SDFF, TRCUT)
│   └── tb/                  # Verification testbench (TRCUT_tb)
│
├── 02_BIST_LFSR_MISR/
│   ├── Report_2_BIST.pdf
│   ├── src/                 # LFSR and MISR components
│   └── tb/                  # BIST simulation testbenches
│
├── 03_JTAG_TAP_Controller/
│   ├── Report_3_JTAG_Blocks.pdf
│   ├── src/                 # TAP Controller, BSC, IR, and BR modules
│   └── tb/                  # FSM and isolated block testbenches
│
├── 04_Top_Level_Integration/
│   ├── Report_4_Final_Chip.pdf
│   ├── src/                 # JTAG_Chip_Top integration module
│   └── tb/                  # Full JTAG protocol testbench
│
├── LICENSE
└── README.md

📖 Detailed Project Documentation
Introduction
This technical report focuses on the design, implementation and verification of a digital circuit with built-in scanning chain control capabilities (Scan Chain), based on the TRCUT (Testable Circuit Under Test) architecture. The object of the study is the isolation and control of a combinational circuit (CUT) using specially modified Flip-Flops (SDFF), which allow switching between normal mode (Normal/Capture Mode) and the control mode (Shift Mode).

Structural Elements
D-Flip Flop (DFF): Works with edge-triggering, meaning the moment the clock (CLK) changes state at the positive edge, the Flip-Flop takes input D. This memory property allows the circuit to "remember" its state.

Scan D-Flip Flop (SDFF): Consists of a simple D flip flop and a multiplexer at its input. When SE = 0 (Normal/Capture Mode), the multiplexer selects the Data Input (DI) and the circuit works normally, executing its logic. When SE = 1 (Shift Mode), the multiplexer selects the Scan Input (SI), and all SDFFs connected in series form a shift register where data moves every clock cycle.

TRCUT Architecture: SDFFs are serially linked together creating a Scan Chain. By setting SE=1, we serially "push" the values into the chain to apply any combination from the Truth Table without directly accessing the inputs of the combinatorial part. With SE=0, the outputs of the logic are stored in the SDFFs.

Testbench Optimization (TRCUT_tb)
Overlapped Scan: The control time was reduced from 9 cycles per vector to just 5 cycles by transitioning to a pipelined logic. The input of the next vector is done at the same time as the output and verification of the results of the current vector.

Temporal Analysis: For N=4 inputs, exhaustive testing takes 8.4 μs. When the number of inputs increases to N=40, the time jumps to 52.1 days, making ATPG (Automatic Test Pattern Generation) methodologies imperative to select a targeted set of control vectors for complex systems.

Pattern Generation (LFSR)
The use of Linear Feedback Shift Registers (LFSR) is the most widely used method for producing test vectors in BIST systems.

The LFSR functions as a pseudorandom vector generator. The 8th degree LFSR used can produce up to 255 different vectors before the sequence is repeated.

The characteristic primitive polynomial used is P(x) = x^8 + x^4 + x^3 + x^2 + 1.

The LFSR must necessarily be initialized to a non-zero state (Seed) to prevent the circuit from locking up.

Signature Analyzer (MISR)
The Multiple Input Shift Register (MISR) acts as the Signature Analyzer. It consists of 16 flip-flops, offering an aliasing error probability of only 2^(-16), which ensures high reliability in the testing.

In each clock cycle, the MISR mixes its content with the new output bit, performing a sequential compression of the responses.

At the end of the healthy circuit simulation, the golden signature receives the fixed value of 7532.

During fault injection, a stuck-at-1 fault was introduced into the combinatorial circuit. The error propagated through the scan chain and was successfully detected, yielding a faulty signature of 3E81.

JTAG Structural Circuits
Bypass Register (BR): A 1-bit shift register that connects TDI to TDO through a single delay cycle. It allows a device not participating in the current test to be bypassed, creating a controlled latency.

Instruction Register (IR) Cell: Consists of a Shift Register for serial data entry and a Latch/Update Register for command stabilization. The Latch FF ensures that the chip logic sees the new command only when the whole sequence is loaded correctly, preventing the chip from executing different commands during the shift.

Boundary Scan Cell (BSC): A smart switch placed between the physical pins of the integrated circuit and its internal logic. It can observe what signals go in or out, or impose its own values on the pins by bypassing the internal logic.

TAP Controller Architecture
The TAP Controller is a 16-state serial Finite State Machine (FSM) that interprets the TMS control signal on the edge of the TCK clock and guides the chip to the appropriate test modes.

Regardless of the current state, if the TMS signal remains high ('1') for 5 consecutive clock cycles, the controller always safely returns to the original Test-Logic-Reset state.

The FSM orchestrates all testing operations, dictating to the BSCs and the IR when to Capture, when to Shift, and when to Update.

Integrated JTAG-CUT Chip
The integrated circuit was designed to allow the control of its proper functioning both at the level of internal logic and at the level of interconnections on the PCB.

In Normal Mode, the circuit operates transparently without being affected by the JTAG infrastructure. In Test Mode, the JTAG infrastructure takes control of the chip pins, allowing test vectors to be imposed and responses read.

The architecture includes the Test Access Port (TAP) with 5 terminals: TCK, TMS, TDI, TDO, and TRST.

Supported Features & Testbench Verification
SAMPLE/PRELOAD ('01'): Provides transparent operation and signal sampling. The outputs of the CUT are captured in the registers, allowing observation without interfering with normal operation.

INTEST ('10'): Performs internal logic testing. The BSC cells cut the connection of the CUT to the outside world and connect it to the internal Update Latches, enforcing the JTAG logic on the inputs of the circuit.

BYPASS ('11'): Provides a rapid access bypass path for the chip in the JTAG chain. The value of the TDI is displayed in the TDO at the first falling edge during the Shift-DR state, with a delay of exactly one TCK cycle.

🛠️ Tools & Technologies
Hardware Description Language: VHDL-2008

Simulation & Verification: Siemens EDA ModelSim / Questa

Synthesis & RTL Viewing: Intel Quartus Prime

Methodologies: DFT, BIST, JTAG (IEEE 1149.1), FSM Design, Fault Injection

✍️ Author
Athanasios Fytilis (5381)

Computer Science & Computer Engineering
