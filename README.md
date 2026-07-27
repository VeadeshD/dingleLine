# Open-Source FPGA FADEC (Full Authority Digital Engine Control)

Welcome to the official repository for the Open-Source FPGA FADEC project. This system is designed to provide highly deterministic, hardware-accelerated telemetry acquisition and control laws for ion thruster propulsion systems. 

## Project Overview
This repository contains the SystemVerilog RTL and verification testbenches for a custom FADEC architecture. The architecture targets initial prototyping on a Lattice iCE40 FPGA, with the ultimate goal of an open-source silicon ASIC tapeout via the Efabless OpenLane flow (SkyWater 130nm PDK).

## Architecture
The FADEC pipeline currently implements:
- **SPI Master (`spi_master.sv`)**: A deterministic, two-block FSM that directly interfaces with external ADCs (e.g., MCP3208) to acquire analog telemetry.
- **Moving Average Filter (`avg_filter.sv`)**: A hardware-accelerated rolling buffer utilizing bit-shift arithmetic to filter electrical noise from the ion thruster in real-time.
- **Sensor Pipeline (`sensor_pipeline.sv`)**: The top-level integration wrapper.

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
