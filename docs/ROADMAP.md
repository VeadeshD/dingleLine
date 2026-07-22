# dingleLine FADEC Project Roadmap

This document outlines my three-phase roadmap for developing the FPGA architecture and propulsion controller for the dingleLine FADEC project.

## Phase 1: The Hardware Data Pipeline (FPGA / SystemVerilog)
**Goal:** Prove I can ingest and route high-speed sensor data at the silicon level.

Before controlling a thruster, I need to reliably read its environment. In this phase, I will ignore the propulsion logic and focus entirely on creating robust IP cores for sensor ingestion.
- **The Build:** I will write a SystemVerilog SPI Master module (`spi_master.sv`) that interfaces with an external Analog-to-Digital Converter (ADC).
- **The Logic:** I will design the module to continuously poll the ADC for voltage and current readings. I will pass this data through a hardware moving-average filter (`moving_avg_filter.sv`) to smooth out sensor noise.
- **Verification:** I will write a testbench (`sensor_pipeline_tb.sv`) to simulate the ADC's serial data stream and run it through Riviera-PRO / Icarus. I will inject timing anomalies and bit-flips into my testbench to prove my IP core recovers gracefully without locking up.

## Phase 2: The Propulsion Control Laws (Software / Hardware Design)
**Goal:** Prove I understand the physics, state management, and safety protocols of electric propulsion.

I will set the FPGA aside and focus on the control logic required to safely operate a gridded ion thruster. It is standard practice to model these state machines in software before ever committing them to hardware logic.
- **The Modeling:** I will use MATLAB (`matlab/control_laws.m`) to define the control laws. I will map out the exact thresholds for the electromagnetic fields and grid voltages during Pre-charge, Ignition, and Steady-State Firing.
- **The Software FSM:** I will implement the finite state machine in standard C (`firmware/propulsion_fsm/propulsion_fsm.c`) on a basic microcontroller. I will program the tripwires—if the simulated current spikes beyond a defined limit, my software must instantly transition to a Safe Shutdown state.
- **The Interface:** I will design a custom schematic in KiCad (`dingle_isolation.kicad_sch`). I will need a board that routes the sensor inputs through isolation circuitry and outputs the PWM signals required to drive the thruster's high-voltage grids.

## Phase 3: The Aerospace Integration (FADEC on FPGA)
**Goal:** Prove I can design a Hardware-in-the-Loop (HIL) system with deterministic, nanosecond reaction times.

This is my capstone. I will migrate the software-based state machine from Phase 2 into the hardware architecture I built in Phase 1.
- **Hardware Acceleration:** I will translate my C/MATLAB state machine into SystemVerilog combinational and sequential logic (`propulsion_fsm.sv`). While software evaluates one line of code at a time, my FPGA will evaluate the entire state of the thruster on every single clock tick.
- **The Integration:** I will wire my Phase 1 SPI ingestion modules directly into my Phase 3 SystemVerilog state machine inside `dingle_fadec_top.sv`. The raw data from the ADC will now instantly dictate the thruster's operating state.
- **The Safety Mechanism:** I will program a hardware interrupt (`safety_interrupt.sv`). If the SPI module detects an over-current event, my combinational logic will sever the PWM drive signals to my KiCad board in a single clock cycle, bypassing the main FSM entirely.
