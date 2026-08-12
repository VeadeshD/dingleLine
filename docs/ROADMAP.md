# dingleLine FADEC Project Roadmap

This document outlines a three-phase roadmap for developing the FPGA architecture and propulsion controller for the dingleLine FADEC project.

## Phase 1: The Hardware Data Pipeline (FPGA / SystemVerilog)
**Goal:** Prove the capability to ingest and route high-speed sensor data at the silicon level.

Before controlling a thruster, it is necessary to reliably read its environment. In this phase, the propulsion logic is bypassed to focus entirely on creating robust IP cores for sensor ingestion.
- **The Build:** A SystemVerilog SPI Master module (`spi_master.sv`) will be written to interface with an external Analog-to-Digital Converter (ADC).
- **The Logic:** The module will be designed to continuously poll the ADC for voltage and current readings. This data will be passed through a hardware moving-average filter (`moving_avg_filter.sv`) to smooth out sensor noise.
- **Verification:** A testbench (`sensor_pipeline_tb.sv`) will be written to simulate the ADC's serial data stream and will be run through Riviera-PRO / Icarus. Timing anomalies and bit-flips will be injected into the testbench to prove the IP core recovers gracefully without locking up.

## Phase 2: The Propulsion Control Laws (Software / Hardware Design)
**Goal:** Prove an understanding of the physics, state management, and safety protocols of electric propulsion.

The FPGA development will be temporarily paused to focus on the control logic required to safely operate a gridded ion thruster. It is standard practice to model these state machines in software before ever committing them to hardware logic.
- **The Modeling:** MATLAB (`matlab/control_laws.m`) will be used to define the control laws. The exact thresholds for the electromagnetic fields and grid voltages during Pre-charge, Ignition, and Steady-State Firing will be mapped out.
- **The Software FSM:** The finite state machine will be implemented in standard C (`firmware/propulsion_fsm/propulsion_fsm.c`) on a basic microcontroller. The tripwires will be programmed—if the simulated current spikes beyond a defined limit, the software must instantly transition to a Safe Shutdown state.
- **The Interface:** A custom schematic will be designed in KiCad (`dingle_isolation.kicad_sch`). A board is required to route the sensor inputs through isolation circuitry and output the PWM signals necessary to drive the thruster's high-voltage grids.

## Phase 3: The Aerospace Integration (FADEC on FPGA)
**Goal:** Prove the ability to design a Hardware-in-the-Loop (HIL) system with deterministic, nanosecond reaction times.

This phase represents the capstone of the project. The software-based state machine from Phase 2 will be migrated into the hardware architecture developed in Phase 1.
- **Hardware Acceleration:** The C/MATLAB state machine will be translated into SystemVerilog combinational and sequential logic (`propulsion_fsm.sv`). While software evaluates one line of code at a time, the FPGA will evaluate the entire state of the thruster on every single clock tick.
- **The Integration:** The Phase 1 SPI ingestion modules will be wired directly into the Phase 3 SystemVerilog state machine inside `dingle_fadec_top.sv`. The raw data from the ADC will now instantly dictate the thruster's operating state.
- **The Safety Mechanism:** A hardware interrupt (`safety_interrupt.sv`) will be programmed. If the SPI module detects an over-current event, the combinational logic will sever the PWM drive signals to the KiCad board in a single clock cycle, bypassing the main FSM entirely.
