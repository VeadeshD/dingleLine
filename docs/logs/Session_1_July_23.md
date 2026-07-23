# Engineering Log: Session 1
**Date:** July 22 - July 23, 2026
**Engineer:** Veadesh
**Focus:** Phase 1 - Hardware Data Pipeline

## Work Accomplished
Today's session was focused on building the foundational hardware logic to read raw telemetry from an external MCP3208 Analog-to-Digital Converter, wiring it together, and proving it works via simulation.

1. **Repository Setup**: Initialized the GitHub repository, cleared out legacy code, and established an aerospace-standard documentation structure.
2. **SPI Master (`spi_master.sv`)**: 
   - Engineered a Two-Block Finite State Machine (FSM).
   - Built a custom Clock Divider to down-sample the 12 MHz system clock to a stable SPI bus frequency.
   - Handled the serial shifting of the ADC command bits and the parallel reconstruction of the 12-bit telemetry.
3. **Moving Average Filter (`moving_avg_filter.sv`)**:
   - Designed a hardware-accelerated filter to eliminate ion thruster electrical noise.
   - Built an 8-slot rolling memory buffer array.
   - Implemented a zero-latency bit-shifting division algorithm (`sum_q[14:3]`) to avoid synthesizing expensive hardware dividers.
4. **Integration & Verification (`sensor_pipeline.sv`)**:
   - Built a top-level wrapper module linking the SPI Master and the Moving Average Filter via internal wires.
   - Authored a comprehensive Testbench (`tb_sensor_pipeline.sv`) generating a fake 12MHz clock and simulating SPI transactions.
   - Transitioned to cloud-based simulation using EDA Playground.
   - Successfully verified clock down-sampling, FSM state transitions, and chip select logic via EPWave waveforms.

## Key Learnings & Architecture Decisions
- Transitioned from blocking (`=`) to non-blocking (`<=`) assignments within `always_ff` blocks to ensure simultaneous flip-flop execution.
- Gated FSM transitions and bit-shifts to the slow clock (`if (clk_div_q == 4'd5)`) to prevent race conditions.
- Utilized bus slicing (`[14:3]`) to elegantly perform binary division by 8.
- Adapted to a cloud-based development workflow by utilizing EDA Playground for Icarus Verilog compilation and EPWave visualization.

## Next Session Goals
- Begin **Phase 2: Propulsion Control Laws**.
- Design the safety logic to analyze the `data_o` stream and implement engine shutdown sequences if telemetry exceeds critical thresholds.
