# 🚀 5-Stage Pipelined RISC-V (RV32I) Processor Core

[![Language](https://img.shields.io/badge/Language-Verilog--2001-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![Simulator](https://img.shields.io/badge/Simulator-Icarus%20Verilog-green.svg)](http://iverilog.icarus.com/)
[![Waveform](https://img.shields.io/badge/Waveform-GTKWave-orange.svg)](http://gtkwave.sourceforge.net/)
[![Architecture](https://img.shields.io/badge/ISA-RISC--V%20RV32I-red.svg)](https://riscv.org/)
[![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

A fully functional, synthesizable **5-Stage Pipelined 32-bit RISC-V (RV32I) Processor Core** implemented in Verilog HDL. This processor implements classical 5-stage pipeline registers, full **Data Forwarding (Bypassing)**, **Load-Use Hazard Stalling**, and **Control Hazard Branch Flushing**.

---

## 📌 Features & Highlights

*   **ISA Support:** Base RV32I integer instruction set architecture.
*   **Pipeline Architecture:** 5 classic pipeline stages (IF, ID, EX, MEM, WB).
*   **Data Hazard Resolution:** Dedicated Hazard Unit providing full EX/MEM and MEM/WB execution bypassing (data forwarding).
*   **Load-Use Stall Mechanism:** Automatic 1-cycle stall bubble insertion on register dependencies following memory load (`lw`) instructions.
*   **Control Hazard Handling:** Branch and jump target calculation with single-cycle speculative instruction flushing on taken branches.
*   **Register File:** 32x32-bit register file with zero register ($x0$) hardwired to `32'h00000000`.
*   **Toolchain Integration:** Pre-configured for simulation and waveform analysis using **Icarus Verilog** and **GTKWave**.

---

## 📸 Waveform Verification

### 1. Data Forwarding Unit (RAW Hazard Resolution)
The Hazard Unit dynamically monitors source register dependencies (`rs1`, `rs2`) in the **EX** stage against target registers (`rd`) in the **EX/MEM** and **MEM/WB** pipeline registers. Data is forwarded directly into the ALU operand multiplexers in the EX stage, preventing pipeline throughput degradation.

![Data Forwarding Waveform](assets/waveform_forwarding.png)

*   `forward_a` / `forward_b` = `2'b10`: Forwards calculated ALU output directly from the EX/MEM pipeline register.
*   `forward_a` / `forward_b` = `2'b01`: Forwards committed writeback data directly from the MEM/WB stage.

### 2. Load-Use Hazard Stalling
Because data read from Data Memory during a `lw` instruction is not available until the end of the MEM stage, data forwarding alone cannot resolve immediate register dependencies. The core automatically stalls execution for 1 clock cycle:

![Load-Use Stall Waveform](assets/waveform_stall.png)

*   `stall_pc` = `1'b1`: Freezes the Program Counter register.
*   `stall_if_id` = `1'b1`: Freezes the IF/ID pipeline register to retain the dependent instruction.
*   `flush_id_ex` = `1'b1`: Clears the ID/EX register control signals, injecting a harmless `NOP` (bubble) into the pipeline.

### 3. Control Hazard (Branch Flushing)
When a branch condition evaluates to true in the Memory stage (`pcsrc = 1`), speculatively fetched instructions in the pipeline must be discarded:

![Branch Flush Waveform](assets/waveform_branch.png)

*   `flush_if_id` = `1'b1` and `flush_id_ex` = `1'b1`: Clears speculatively fetched pipeline registers.
*   The PC updates directly to `mem_branch_target` on the next active clock edge.

---

## 🔬 Microarchitecture Stage Breakdown

### 1. Instruction Fetch (IF)
*   **Program Counter (`pc.v`):** Maintains the current instruction memory address. Supports holds driven by `stall_pc`.
*   **Instruction Memory (`instr_mem.v`):** Word-addressable instruction memory pre-filled with binary/hex machine code via `$readmemh`.
*   **IF/ID Pipeline Register (`if_id_reg.v`):** Registers PC and fetched instruction word for the Decode stage. Supports `stall` and `flush`.

### 2. Instruction Decode (ID)
*   **Register File (`reg_file.v`):** Dual asynchronous read ports, single synchronous write port on falling/rising edge.
*   **Immediate Generator (`imm_gen.v`):** Asynchronously decodes and sign-extends 32-bit constants for I-type, S-type, B-type, U-type, and J-type instruction formats.
*   **Control Unit (`control_unit.v` & `alu_decoder.v`):** Decodes main opcodes, `funct3`, and `funct7` fields to produce control vectors (`reg_write`, `alu_src`, `mem_read`, `mem_write`, `mem_to_reg`, `branch`, `jump`, `alu_op`).
*   **ID/EX Pipeline Register (`id_ex_reg.v`):** Registers decode state, operands, and control bits for execution. Supports synchronous `flush`.

### 3. Execute (EX)
*   **Operand Multiplexers:** Selects between raw register output, EX/MEM forwarded result, or MEM/WB writeback data based on `forward_a` and `forward_b`.
*   **ALU Operand B MUX:** Chooses between register operand or sign-extended immediate payload (`alu_src`).
*   **Arithmetic Logic Unit (`alu.v`):** Computes arithmetic, logical, comparison, and shift operations. Generates condition flags (`zero`).
*   **Branch Address Generator:** Calculates target jump address: $\text{Branch Target} = \text{EX\_PC} + \text{EX\_ImmExt}$.
*   **EX/MEM Pipeline Register (`ex_mem_reg.v`):** Registers ALU outputs, store data, target register indices, and control flags for Memory access.

### 4. Memory Access (MEM)
*   **Data Memory (`data_mem.v`):** Word-addressable RAM supporting synchronous write (`sw`) and asynchronous read (`lw`) operations.
*   **Branch Condition Logic:** Evaluates $PCSRC = (\text{Branch} \land \text{Zero}) \lor \text{Jump}$. Updates Next-PC multiplexer in the Fetch stage.
*   **MEM/WB Pipeline Register (`mem_wb_reg.v`):** Holds loaded data, ALU calculation results, target register address, and writeback control signals.

### 5. Writeback (WB)
*   **Writeback MUX:** Selects between Data Memory read value (`mem_to_reg = 1`) or ALU output result (`mem_to_reg = 0`).
*   Commits execution output back into target register `rd` when `wb_reg_write = 1`.

---

## ⚡ Hazard Detection & Resolution Logic

### Forwarding Decision Table
The Hazard Unit constantly evaluates register source and destination indices across stages:

| Signal | Condition Code | Data Route Source |
| :---: | :--- | :--- |
| `forward_a = 2'b10` | `mem_reg_write` $\land$ (`mem_rd_addr` $\neq$ 0) $\land$ (`mem_rd_addr` == `ex_rs1_addr`) | Forward from **EX/MEM Stage** |
| `forward_a = 2'b01` | `wb_reg_write` $\land$ (`wb_rd_addr` $\neq$ 0) $\land$ (`wb_rd_addr` == `ex_rs1_addr`) | Forward from **MEM/WB Stage** |
| `forward_a = 2'b00` | No Dependency Hazard Detected | Standard **Register File Output** |
| `forward_b = 2'b10` | `mem_reg_write` $\land$ (`mem_rd_addr` $\neq$ 0) $\land$ (`mem_rd_addr` == `ex_rs2_addr`) | Forward from **EX/MEM Stage** |
| `forward_b = 2'b01` | `wb_reg_write` $\land$ (`wb_rd_addr` $\neq$ 0) $\land$ (`wb_rd_addr` == `ex_rs2_addr`) | Forward from **MEM/WB Stage** |
| `forward_b = 2'b00` | No Dependency Hazard Detected | Standard **Register File Output** |

### Stalling and Flushing Code Logic
```verilog
// Load-Use Hazard Stall Conditions
if (ex_mem_read && (ex_rd_addr != 0) && 
   ((ex_rd_addr == id_rs1_addr) || (ex_rd_addr == id_rs2_addr))) begin
    stall_pc    = 1'b1; // Freeze PC update
    stall_if_id = 1'b1; // Hold current IF/ID instruction
    flush_id_ex = 1'b1; // Clear ID/EX pipeline register (Inject NOP)
end

// Branch Misprediction / Control Hazard Flush
if (pcsrc) begin
    flush_if_id = 1'b1; // Flush speculative instruction in IF/ID
    flush_id_ex = 1'b1; // Flush speculative instruction in ID/EX
end
