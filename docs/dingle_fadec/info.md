<!---

This file is used to generate my project datasheet. Please fill in the information below and delete any unused
sections.

I can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

My **dingle_fadec** project is a Full Authority Digital Engine Control (FADEC) system designed for electric propulsion—specifically, a gridded ion thruster. I have designed it to operate via a robust, hardware-accelerated state machine with nanosecond deterministic reactions.

I have broken down the system into modular components:
1. **SPI Data Pipeline**: My system ingest sensor data directly from an ADC using a SystemVerilog SPI Master.
2. **Signal Filtering**: The polled voltage and current readings pass through my parameterizable hardware moving-average filter to smooth out sensor noise.
3. **Propulsion FSM**: I am implementing a hardware-accelerated control law state machine, translating MATLAB/C logic to SystemVerilog, to govern Pre-charge, Ignition, and Steady-State Firing sequences.
4. **Safety Interrupts**: I am including a purely combinational fault-detection block that continuously monitors the sensor pipeline. If my system detects an over-current event, it severs the PWM grid drive outputs in a single clock cycle to ensure a Safe Shutdown.

## How to test

My design verification involves multiple simulation environments:
- **Pipeline Unit Tests**: I will run `make sim_spi_master_src` and `make sim_sensor_pipeline_src` to verify my SPI ingestion and filtering.
- **HIL Fault Injection**: My integrated testbench simulates the ADC SPI interface while injecting timing anomalies, bit-flips, and over-current events to verify the 1-clock-cycle shutdown response.
- **FPGA Testing**: I can flash the design onto an iCE40 FPGA (`make cram`) coupled with an external microcontroller feeding simulated analog signals.

## External hardware

My project interfaces with specific external aerospace and PCB components:
- **Analog-to-Digital Converter (ADC)**: I am polling this over an SPI bus for real-time telemetry (Voltage / Current).
- **Isolation Schematic Board (KiCad)**: I will build a custom PCB that safely isolates sensor inputs and handles the high-voltage PWM signals required to drive the thruster grids.
- **Microcontroller**: I am using this for initial software-in-the-loop validation of my C state machine before full FPGA hardware migration.
