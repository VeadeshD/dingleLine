# Project Timeline: FADEC Development

This document outlines my high-level timeline and milestones for the design, verification, and implementation of my open-source FPGA-based Full Authority Digital Engine Control (FADEC).

## Milestone 1: Hardware Data Pipeline
**Status:** Completed
**Goal:** Establish my deterministic telemetry acquisition from the Ion Thruster ADC.
- [x] Scaffold my project and repository structure
- [x] Design my SPI Master Module (`spi_master.sv`)
- [x] Design my Moving Average Filter Module (`avg_filter.sv`)
- [x] Implement my Top-Level Sensor Pipeline (`sensor_pipeline.sv`)
- [x] Verify my logic via Testbench and EPWave/GTKWave simulation

## Milestone 2: Propulsion Control Laws
**Status:** In Progress (Next)
**Goal:** Implement my safety logic and PID control to regulate thruster flow valves based on my filtered telemetry.
- [ ] Define my engine operating bounds (Max voltage, over-current thresholds)
- [ ] Implement my State Machine for Startup, Steady-State, and Emergency Shutdown
- [ ] Design my PWM (Pulse Width Modulation) generation for valve control
- [ ] Verify my Control Laws via simulation

## Milestone 3: Open-Source Silicon Integration
**Status:** Pending
**Goal:** Prepare my verified FADEC RTL for physical tapeout via the OpenLane/Sky130 flow.
- [ ] Synthesize my RTL for Sky130 PDK
- [ ] Complete my floorplanning and routing
- [ ] Finalize my `info.md` tapeout datasheet
- [ ] Submit my GDSII file for silicon fabrication
