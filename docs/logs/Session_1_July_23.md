# Engineering Log: Session 1
**Date:** July 22 - July 23, 2026
**Engineer:** Veadesh
**Focus:** Phase 1 - Hardware Data Pipeline

## Work Accomplished
Today my session was focused on building my foundational hardware logic to read raw telemetry from an external MCP3208 Analog-to-Digital Converter, wiring it together, and proving it works via simulation.

1. **Repository Setup**: I initialized the GitHub repository, cleared out my legacy code, and established an aerospace-standard documentation structure.
2. **SPI Master (`spi_master.sv`)**: 
   - I engineered a Two-Block Finite State Machine (FSM).
   - I built a custom Clock Divider to down-sample my 12 MHz system clock to a stable SPI bus frequency.
   - I handled the serial shifting of my ADC command bits and the parallel reconstruction of my 12-bit telemetry.
3. **Moving Average Filter (`moving_avg_filter.sv`)**:
   - I designed a hardware-accelerated filter to eliminate my ion thruster electrical noise.
   - I built an 8-slot rolling memory buffer array.
   - I implemented a zero-latency bit-shifting division algorithm (`sum_q[14:3]`) to avoid synthesizing expensive hardware dividers.
4. **Integration & Verification (`sensor_pipeline.sv`)**:
   - I built a top-level wrapper module linking my SPI Master and my Moving Average Filter via internal wires.
   - I authored a comprehensive Testbench (`tb_sensor_pipeline.sv`) generating a fake 12MHz clock and simulating SPI transactions.
   - I transitioned to cloud-based simulation using EDA Playground.
   - I successfully verified my clock down-sampling, FSM state transitions, and chip select logic via EPWave waveforms.

## Key Learnings & Architecture Decisions
- I transitioned from blocking (`=`) to non-blocking (`<=`) assignments within my `always_ff` blocks to ensure simultaneous flip-flop execution.
- I gated my FSM transitions and bit-shifts to the slow clock (`if (clk_div_q == 4'd5)`) to prevent race conditions.
- I utilized bus slicing (`[14:3]`) to elegantly perform binary division by 8.
- I adapted to a cloud-based development workflow by utilizing EDA Playground for Icarus Verilog compilation and EPWave visualization.

## Next Session Goals
- I will begin **Phase 2: Propulsion Control Laws**.
- I will design the safety logic to analyze my `data_o` stream and implement engine shutdown sequences if my telemetry exceeds critical thresholds.
