# Phase 1 Progress: SPI Master Implementation

## Overview
I have successfully implemented the first major component of my FADEC Hardware Data Pipeline: The **SPI Master** (`spi_master.sv`). I designed this module to directly interface with an external Analog-to-Digital Converter (like the MCP3208) to retrieve real-time analog telemetry (voltage and current) from my ion thruster and convert it into a digital 12-bit format for my FPGA.

## Architectural Highlights

### 1. Two-Block FSM Design
I built this module adhering to aerospace-grade, deterministic SystemVerilog standards by strictly separating sequential memory from combinational logic:
- **`always_ff`**: Manages my strict clock synchronization, ensuring all memory registers (State, Shift Register, Counters) update simultaneously on the rising edge of the system clock. It also enforces a hardware-level safety reset (`rst_n`) to force my thruster monitoring into an `IDLE` state upon boot.
- **`always_comb`**: Houses my decision logic and the Finite State Machine (FSM), evaluating the next state instantly without clock latency.

### 2. Custom Clock Divider
Because my iCE40 FPGA system clock operates significantly faster (e.g., 12+ MHz) than the maximum allowable SPI clock for the ADC (~1-2 MHz), I had to slow it down:
- I implemented a **Clock Divider** (`clk_div_q`) that mathematically down-samples the system clock.
- It generates a slow, stable square wave (`spi_clk_q`) which I route directly to the physical `spi_sclk_o` pin.
- I wrapped the `SEND_CMD` and `READ_DATA` FSM states in synchronization logic (`if (clk_div_q == 4'd5)`) to ensure my bits are only shifted exactly when the slow SPI clock ticks.

### 3. Shift Register Architecture
To handle the serial nature of the SPI protocol over my single `MISO` wire:
- I utilized a 12-bit shift register (`shift_reg_q`).
- During `SEND_CMD`, I shift out the 5-bit command configuration (Start Bit, Single-Ended Mode, and Channel Selection) via concatenation: `{shift_reg_q[10:0], 1'b0}`.
- During `READ_DATA`, I capture incoming serial blips from the ADC and re-assemble them into a parallel 12-bit word: `{shift_reg_q[10:0], spi_miso_i}`.

### 4. Physical Analog Delay (The `SAMPLE` State)
I incorporated a dedicated `SAMPLE` state in my FSM. This acts as a hardware "dummy" cycle to accommodate the physical limitations of the ADC, allowing its internal Sample-and-Hold capacitor the necessary time (1.5 clock cycles) to physically charge and lock the incoming analog voltage before digitization begins.

### 5. The Moving Average Filter (`moving_avg_filter.sv`)
To ensure my FADEC safety logic does not trigger false engine shutdowns due to the extreme electrical noise characteristic of ion thrusters, I implemented a hardware-accelerated **Moving Average Filter**.

- **The Rolling Buffer**: The module maintains an array of eight 12-bit registers (`buffer_q[0:7]`), acting as a short-term memory bank for the last 8 telemetry snapshots from the ADC.
- **The Running Sum**: Rather than looping through the array to recalculate the total on every clock cycle, I implemented a running sum (`sum_q`). When a new reading arrives, the logic simply subtracts the oldest reading (`buffer_q[7]`) and adds the new reading (`data_i`), keeping the sum perfectly accurate.
- **Zero-Latency Division**: Because division logic is highly inefficient in silicon, I sized my array to exactly $2^3$ (8) samples. To calculate the final average, I physically wired the top 12 bits of the 15-bit sum directly to the output pins (`data_o = sum_q[14:3]`). This effectively bit-shifts the sum to the right by 3, perfectly dividing the total by 8 in a single, combinational clock cycle!

## Next Steps
With both the `spi_master.sv` and `moving_avg_filter.sv` core modules written, the final step in Phase 1 is **Integration and Verification**. I will need to construct a Top-Level pipeline module (`sensor_pipeline.sv`) to physically wire the SPI Master's outputs into the Filter's inputs, and then write a testbench to simulate the hardware.
