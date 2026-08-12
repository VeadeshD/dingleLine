# Open-Source FPGA FADEC (Full Authority Digital Engine Control)

Welcome to the official repository for the Open-Source FPGA FADEC project. This system is designed to provide highly deterministic, hardware-accelerated telemetry acquisition and control laws for ion thruster propulsion systems. 

## Project Overview
This repository contains the SystemVerilog RTL and verification testbenches for a custom FADEC architecture. The architecture targets initial prototyping on a Lattice iCE40 FPGA, with the ultimate goal of an open-source silicon ASIC tapeout via the Efabless OpenLane flow (SkyWater 130nm PDK).

## Architecture
The FADEC pipeline currently implements:
- **SPI Master (`spi_master.sv`)**: A deterministic, two-block FSM that directly interfaces with external ADCs (e.g., MCP3208) to acquire analog telemetry.
- **Moving Average Filter (`avg_filter.sv`)**: A hardware-accelerated rolling buffer utilizing bit-shift arithmetic to filter electrical noise from the ion thruster in real-time.
- **Sensor Pipeline (`sensor_pipeline.sv`)**: The top-level integration wrapper.

## Physical Hardware Integration
The RTL architecture has been successfully synthesized and physically proven on hardware:
- **Lattice iCE40HX8K FPGA**: Runs the core DSP and FADEC control laws.
- **MCP3208 12-bit ADC**: Wired via physical SPI pins to convert live analog voltage (simulated engine sensors) into digital telemetry.
- **Raspberry Pi Pico Ground Station**: Receives continuous UART telemetry packets at 115200 baud. Custom embedded C firmware (`main.c`) utilizes a mathematical synchronization filter to guarantee robust packet alignment and live monitoring.
- **Physical State Indicators**: The FADEC control states (Fuel Valve PWM, Emergency Alarm, and Engine Shutdown) are physically mapped to external LEDs, instantly visually confirming hardware interrupts and state transitions.

## Documentation
- **[Architectural Walkthrough](docs/WALKTHROUGH.md)**: Detailed breakdowns of the RTL design, state machines, and clock domains.
- **[Development Timeline](docs/TIMELINE.md)**: Current project milestones and roadmap.
- **[Engineering Logs](docs/logs/)**: Session-by-session documentation of engineering decisions and progress.

## Verification
The hardware pipeline is fully verified using Icarus Verilog and GTKWave.
To compile and simulate the pipeline:
```bash
iverilog -g2012 -o pipeline_sim verilog/rtl/dingle_fadec/spi_master.sv verilog/rtl/dingle_fadec/avg_filter.sv verilog/rtl/dingle_fadec/sensor_pipeline.sv verilog/dv/dingle_fadec/tb_sensor_pipeline.sv
vvp pipeline_sim
```

## Methodology & Acknowledgments
**Note on AI Usage:** The core system architecture, physical bounds, state machine thresholds, and hardware integration strategy for this FADEC project were manually engineered. LLM AI tools were utilized to accelerate SystemVerilog syntax generation and format documentation strictly to IEEE academic standards.
