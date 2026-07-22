<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The **dingle_fadec** project is a Full Authority Digital Engine Control (FADEC) system designed for electric propulsion—specifically, a gridded ion thruster. It operates via a robust, hardware-accelerated state machine with nanosecond deterministic reactions.

The system is broken down into modular components:
1. **SPI Data Pipeline**: Ingests sensor data directly from an ADC using a SystemVerilog SPI Master.
2. **Signal Filtering**: Polled voltage and current readings pass through a parameterizable hardware moving-average filter to smooth sensor noise.
3. **Propulsion FSM**: A hardware-accelerated control law state machine translating MATLAB/C logic to SystemVerilog to govern Pre-charge, Ignition, and Steady-State Firing sequences.
4. **Safety Interrupts**: A purely combinational fault-detection block that continuously monitors the sensor pipeline. If an over-current event is detected, it severs the PWM grid drive outputs in a single clock cycle to ensure Safe Shutdown.

## How to test

The design verification involves multiple simulation environments:
- **Pipeline Unit Tests**: Run `make sim_spi_master_src` and `make sim_sensor_pipeline_src` to verify the SPI ingestion and filtering.
- **HIL Fault Injection**: An integrated testbench simulates the ADC SPI interface while injecting timing anomalies, bit-flips, and over-current events to verify the 1-clock-cycle shutdown response.
- **FPGA Testing**: The design can be flashed onto an iCE40 FPGA (`make cram`) coupled with an external microcontroller feeding simulated analog signals.

## External hardware

This project interfaces with specific external aerospace and PCB components:
- **Analog-to-Digital Converter (ADC)**: Polled over an SPI bus for real-time telemetry (Voltage / Current).
- **Isolation Schematic Board (KiCad)**: A custom PCB that safely isolates sensor inputs and handles the high-voltage PWM signals required to drive the thruster grids.
- **Microcontroller**: Used for initial software-in-the-loop validation of the C state machine before full FPGA hardware migration.
