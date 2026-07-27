# Bill of Materials (BOM)
**Project:** FPGA FADEC Hardware-in-the-Loop (HIL) Prototype

This document outlines the physical hardware required to build a breadboard prototype of the FADEC system. This setup will facilitate the flashing of Verilog code onto physical silicon and simulate ion thruster telemetry using physical knobs (potentiometers) and LEDs.

## 1. The Brain (FPGA Development Board)
To execute the open-source Verilog code in a physical environment, a Lattice iCE40 development board is required. The open-source toolchain (Yosys, NextPNR, IceStorm) fully supports these boards.
- **Recommended Item:** [Lattice iCEstick Evaluation Kit (ICE40HX1K-STICK-EVN)](https://www.latticesemi.com/icestick)
- **Rationale:** It functions as a blank slate of silicon. It features a USB port to flash the bitstream directly from a computer, and provides sufficient pins to wire the ADC and LEDs.

## 2. The Analog-to-Digital Converter (ADC)
This is the chip the `spi_master.sv` module was specifically engineered to communicate with.
- **Recommended Item:** **Microchip MCP3208-CI/P**
- **Rationale:** It converts analog voltages into digital 12-bit SPI signals. 
- **CRITICAL NOTE:** The **DIP (Dual In-line Package)** version must be procured. DIP chips feature long, through-hole legs that can plug directly into a breadboard. The SOIC surface-mount version cannot be plugged into a standard breadboard.

## 3. Simulated Sensors (Hardware-in-the-Loop)
A method to physically generate variable voltages to feed into the ADC is necessary to simulate temperature and pressure readings.
- **Recommended Items:** **10kΩ Linear Potentiometers (Breadboard Friendly)**
- **Rationale:** A potentiometer functions as a variable resistor. One side is connected to 3.3V, the other to ground, and the middle pin to the ADC. Adjusting the potentiometer smoothly scales the voltage from 0 to 3.3V, accurately simulating a rising sensor reading. 

## 4. Simulated Actuators 
A mechanism is required to observe the decisions made by the control laws (e.g., opening a valve, triggering an emergency shutdown).
- **Recommended Items:** **Standard 5mm LEDs (Red, Green, Blue) & 330Ω Resistors**
- **Rationale:** The output pins of the FPGA will be wired to these LEDs. If the code detects an over-pressure event and triggers a shutdown, the "Thruster Valve" LED will turn off and the "Emergency Alarm" red LED will turn on.

## 5. Prototyping Essentials
To wire all components together without soldering, basic prototyping equipment is required.
- **Breadboard:** A standard 830-point solderless breadboard.
- **Jumper Wires:** A bundle of "Male-to-Male" and "Male-to-Female" Dupont jumper wires to connect the FPGA pins to the breadboard.

*(Note: Almost all of these items can be sourced at low cost from electronics distributors such as DigiKey, Mouser, or standard kits on Amazon).*
