# Project Timeline: FADEC Development

This document outlines the high-level timeline and milestones for the design, verification, and implementation of the open-source FPGA-based Full Authority Digital Engine Control (FADEC).

## Milestone 1: Hardware Data Pipeline
**Status:** Completed
**Goal:** Establish deterministic telemetry acquisition from the Ion Thruster ADC.
- [x] Scaffold project and repository structure
- [x] Design SPI Master Module (`spi_master.sv`)
- [x] Design Moving Average Filter Module (`avg_filter.sv`)
- [x] Implement Top-Level Sensor Pipeline (`sensor_pipeline.sv`)
- [x] Verify logic via Testbench and EPWave/GTKWave simulation

## Milestone 2: Propulsion Control Laws
**Status:** Completed
**Goal:** Implement safety logic and PID control to regulate thruster flow valves based on filtered telemetry.
- [x] Define engine operating bounds (Max voltage, over-current thresholds)
- [x] Implement State Machine for Startup, Steady-State, and Emergency Shutdown
- [x] Design PWM (Pulse Width Modulation) generation for valve control
- [x] Verify Control Laws via simulation

## Milestone 3: Physical Hardware Prototyping
**Status:** Completed
**Goal:** Deploy the verified RTL to a physical FPGA to prove the FADEC logic in the real world with real analog sensors.
- [x] Synthesize and flash bitstream to Lattice iCE40HX8K Breakout Board
- [x] Implement hardware UART transmitter for live ground station telemetry
- [x] Write embedded C firmware for the Raspberry Pi Pico 2 Ground Station
- [x] Integrate physical MCP3208 ADC, potentiometer, and status LEDs via breadboard
- [x] Debug and mathematically resolve hardware SPI timing and UART synchronization glitches

## Milestone 4: Open-Source Silicon Integration
**Status:** Pending
**Goal:** Prepare verified FADEC RTL for physical tapeout via the Efabless OpenLane/Sky130 flow.
- [ ] Synthesize RTL for Sky130 PDK
- [ ] Complete floorplanning and routing
- [ ] Finalize `info.md` tapeout datasheet
- [ ] Submit GDSII file for silicon fabrication
