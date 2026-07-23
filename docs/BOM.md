# Bill of Materials (BOM)
**Project:** FPGA FADEC Hardware-in-the-Loop (HIL) Prototype

This document outlines the physical hardware I require to build a breadboard prototype of my FADEC system. This setup will allow me to flash my Verilog code onto physical silicon and simulate my ion thruster telemetry using physical knobs (potentiometers) and LEDs.

## 1. The Brain (FPGA Development Board)
To run my open-source Verilog code in the real world, I need a Lattice iCE40 development board. The open-source toolchain (Yosys, NextPNR, IceStorm) fully supports these.
- **Recommended Item:** [Lattice iCEstick Evaluation Kit (ICE40HX1K-STICK-EVN)](https://www.latticesemi.com/icestick)
- **Why I need it:** It is essentially a blank slate of silicon. It has a USB port so I can flash my bitstream directly from my computer, and plenty of pins sticking out so I can wire up my ADC and LEDs.

## 2. The Analog-to-Digital Converter (ADC)
This is the chip my `spi_master.sv` module was specifically engineered to communicate with.
- **Recommended Item:** **Microchip MCP3208-CI/P**
- **Why I need it:** It takes analog voltages and converts them into digital 12-bit SPI signals. 
- **CRITICAL NOTE:** I must make sure I buy the **DIP (Dual In-line Package)** version. DIP chips have long, through-hole legs that can plug directly into a breadboard. I cannot buy the SOIC surface-mount version, as I won't be able to plug it in!

## 3. The "Fake" Sensors (Hardware-in-the-Loop)
I need a way to physically generate variable voltages to feed into my ADC to fake my temperature and pressure readings.
- **Recommended Items:** **10kΩ Linear Potentiometers (Breadboard Friendly)**
- **Why I need it:** A potentiometer is a twistable dial. I connect one side to 3.3V, the other to Ground, and the middle pin to my ADC. As I twist the dial, the voltage smoothly scales from 0 to 3.3V, perfectly simulating a rising sensor reading. 

## 4. The "Fake" Actuators 
I need a way to see what my control laws decide to do (e.g., open a valve, trigger an emergency shutdown).
- **Recommended Items:** **Standard 5mm LEDs (Red, Green, Blue) & 330Ω Resistors**
- **Why I need it:** I will wire the output pins of my FPGA to these LEDs. If my code detects an over-pressure event and triggers a shutdown, I will physically see my "Thruster Valve" LED turn off and my "Emergency Alarm" red LED turn on!

## 5. Prototyping Essentials
To wire everything together without soldering, I need the basics.
- **Breadboard:** A standard 830-point solderless breadboard.
- **Jumper Wires:** A bundle of "Male-to-Male" and "Male-to-Female" Dupont jumper wires to connect my FPGA pins to my breadboard.

*(Note: Almost all of these items can be sourced extremely cheaply from electronics distributors like DigiKey, Mouser, or even standard kits on Amazon).*
