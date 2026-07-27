<!---

This file is used to generate my project datasheet. Please fill in the information below and delete any unused
sections.

I can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The **dingle_fadec** project is a Full Authority Digital Engine Control (FADEC) system designed for electric propulsion—specifically, a gridded ion thruster. It operates via a robust, hardware-accelerated state machine with nanosecond deterministic reactions.

The system is broken down into the following modular components:
1. **SPI Data Pipeline**: Sensor data is ingested directly from an ADC using a SystemVerilog SPI Master.
2. **Signal Filtering**: Polled voltage and current readings pass through a parameterizable hardware moving-average filter to attenuate sensor noise.
3. **Propulsion FSM**: A hardware-accelerated control law state machine, translated from MATLAB/C logic to SystemVerilog, governs the Pre-charge, Ignition, and Steady-State Firing sequences.
4. **Safety Interrupts**: A purely combinational fault-detection block continuously monitors the sensor pipeline. Upon detecting an over-current event, the system severs the PWM grid drive outputs within a single clock cycle to execute a safe shutdown.

## How to test

Design verification involves multiple simulation environments:
- **Pipeline Unit Tests**: Running `make sim_spi_master_src` and `make sim_sensor_pipeline_src` verifies the SPI ingestion and filtering stages.
- **HIL Fault Injection**: An integrated testbench simulates the ADC SPI interface while injecting timing anomalies, bit-flips, and over-current events to verify the 1-clock-cycle shutdown response.
- **FPGA Testing**: The design can be flashed onto an iCE40 FPGA (`make cram`) coupled with an external microcontroller that feeds simulated analog signals.

## External hardware

The project interfaces with specific external aerospace and PCB components:
- **Analog-to-Digital Converter (ADC)**: Polled over an SPI bus to acquire real-time telemetry (Voltage / Current).
- **Isolation Schematic Board (KiCad)**: A custom PCB safely isolates sensor inputs and handles the high-voltage PWM signals required to drive the thruster grids.
- **Microcontroller**: Utilized for initial software-in-the-loop validation of the C state machine prior to full FPGA hardware migration.
