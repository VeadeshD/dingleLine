# Bill of Materials (BOM)
**Project:** FPGA FADEC Hardware-in-the-Loop (HIL) Prototype

This document outlines the physical hardware required to build a breadboard prototype of the FADEC system. This setup will allow you to flash your Verilog code onto physical silicon and simulate ion thruster telemetry using physical knobs (potentiometers) and LEDs.

## 1. The Brain (FPGA Development Board)
To run your open-source Verilog code in the real world, you need a Lattice iCE40 development board. The open-source toolchain (Yosys, NextPNR, IceStorm) fully supports these.
- **Recommended Item:** [Lattice iCEstick Evaluation Kit (ICE40HX1K-STICK-EVN)](https://www.latticesemi.com/icestick)
- **Why you need it:** It is essentially a blank slate of silicon. It has a USB port to flash your bitstream directly from your computer, and plenty of pins sticking out to wire up your ADC and LEDs.

## 2. The Analog-to-Digital Converter (ADC)
This is the chip your `spi_master.sv` module was specifically engineered to communicate with.
- **Recommended Item:** **Microchip MCP3208-CI/P**
- **Why you need it:** It takes analog voltages and converts them into digital 12-bit SPI signals. 
- **CRITICAL NOTE:** Make sure you buy the **DIP (Dual In-line Package)** version. DIP chips have long, through-hole legs that can plug directly into a breadboard. Do not buy the SOIC surface-mount version, as you won't be able to plug it in!

## 3. The "Fake" Sensors (Hardware-in-the-Loop)
We need a way to physically generate variable voltages to feed into the ADC to fake temperature and pressure readings.
- **Recommended Items:** **10kΩ Linear Potentiometers (Breadboard Friendly)**
- **Why you need it:** A potentiometer is a twistable dial. You connect one side to 3.3V, the other to Ground, and the middle pin to your ADC. As you twist the dial, the voltage smoothly scales from 0 to 3.3V, perfectly simulating a rising sensor reading. 

## 4. The "Fake" Actuators 
We need a way to see what your control laws decide to do (e.g., open a valve, trigger an emergency shutdown).
- **Recommended Items:** **Standard 5mm LEDs (Red, Green, Blue) & 330Ω Resistors**
- **Why you need it:** You will wire the output pins of your FPGA to these LEDs. If your code detects an over-pressure event and triggers a shutdown, you will physically see the "Thruster Valve" LED turn off and the "Emergency Alarm" red LED turn on!

## 5. Prototyping Essentials
To wire everything together without soldering, you need the basics.
- **Breadboard:** A standard 830-point solderless breadboard.
- **Jumper Wires:** A bundle of "Male-to-Male" and "Male-to-Female" Dupont jumper wires to connect the FPGA pins to the breadboard.

*(Note: Almost all of these items can be sourced extremely cheaply from electronics distributors like DigiKey, Mouser, or even standard kits on Amazon).*
