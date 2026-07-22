# dingleLine FADEC Project Roadmap

This document outlines the three-phase roadmap for developing the FPGA architecture and propulsion controller for the dingleLine FADEC project.

## Phase 1: The Hardware Data Pipeline (FPGA / SystemVerilog)
**Goal:** Prove you can ingest and route high-speed sensor data at the silicon level.

Before controlling a thruster, you need to reliably read its environment. In this phase, ignore the propulsion logic and focus entirely on creating robust IP cores for sensor ingestion.
- **The Build:** Write a SystemVerilog SPI Master module (`spi_master.sv`) that interfaces with an external Analog-to-Digital Converter (ADC).
- **The Logic:** Design the module to continuously poll the ADC for voltage and current readings. Pass this data through a hardware moving-average filter (`moving_avg_filter.sv`) to smooth out sensor noise.
- **Verification:** Write a testbench (`sensor_pipeline_tb.sv`) to simulate the ADC's serial data stream and run it through Riviera-PRO / Icarus. Inject timing anomalies and bit-flips into your testbench to prove your IP core recovers gracefully without locking up.

## Phase 2: The Propulsion Control Laws (Software / Hardware Design)
**Goal:** Prove you understand the physics, state management, and safety protocols of electric propulsion.

Set the FPGA aside. Focus on the control logic required to safely operate a gridded ion thruster. It is standard practice to model these state machines in software before ever committing them to hardware logic.
- **The Modeling:** Use MATLAB (`matlab/control_laws.m`) to define the control laws. Map out the exact thresholds for the electromagnetic fields and grid voltages during Pre-charge, Ignition, and Steady-State Firing.
- **The Software FSM:** Implement the finite state machine in standard C (`firmware/propulsion_fsm/propulsion_fsm.c`) on a basic microcontroller. Program the tripwires—if the simulated current spikes beyond a defined limit, the software must instantly transition to a Safe Shutdown state.
- **The Interface:** Design a custom schematic in KiCad (`dingle_isolation.kicad_sch`). You will need a board that routes the sensor inputs through isolation circuitry and outputs the PWM signals required to drive the thruster's high-voltage grids.

## Phase 3: The Aerospace Integration (FADEC on FPGA)
**Goal:** Prove you can design a Hardware-in-the-Loop (HIL) system with deterministic, nanosecond reaction times.

This is the capstone. You will migrate the software-based state machine from Phase 2 into the hardware architecture you built in Phase 1.
- **Hardware Acceleration:** Translate your C/MATLAB state machine into SystemVerilog combinational and sequential logic (`propulsion_fsm.sv`). Software evaluates one line of code at a time; your FPGA will evaluate the entire state of the thruster on every single clock tick.
- **The Integration:** Wire your Phase 1 SPI ingestion modules directly into your Phase 3 SystemVerilog state machine inside `dingle_fadec_top.sv`. The raw data from the ADC now instantly dictates the thruster's operating state.
- **The Safety Mechanism:** Program a hardware interrupt (`safety_interrupt.sv`). If the SPI module detects an over-current event, the combinational logic should sever the PWM drive signals to your KiCad board in a single clock cycle, bypassing the main FSM entirely.
