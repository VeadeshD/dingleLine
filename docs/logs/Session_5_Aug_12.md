# Session 5: August 12, 2026 - Physical Hardware Integration & Grand Finale

## Goals
- Wire the physical MCP3208 12-bit ADC and potentiometer to the Lattice FPGA.
- Configure external breadboard LEDs to visualize the FADEC control states.
- Resolve any hardware integration bugs between the Analog inputs, FPGA DSP, and Pico Ground Station.
- Finalize the open-source documentation and portfolio assets.

## Tasks Completed

### 1. Physical Wiring & Pin Mapping
- Wired the MCP3208 ADC and a 10K Potentiometer on a breadboard, powering them from the FPGA's 3.3V rail.
- Updated `support/fpga/pinmap.pcf` to route the SPI interface to physical pins (A9, B9, A10, A11) on the Lattice Breakout Board.
- Updated `fpga_top.sv` to expose the FADEC FSM outputs (`valve_pwm_o`, `alarm_o`, `shutdown_flag_o`) and routed them to new external pins (A16, B15, A15).
- Wired external LEDs (Green, Red, Yellow) to visualize the Valve, Alarm, and Shutdown states of the engine.

### 2. Debugging the SPI Timing Glitch (Values maxing out at 1792)
- **The Symptom:** When turning the potentiometer all the way up to 3.3V, the Pico Ground Station only reported a maximum value of `1792` instead of the expected `4095`.
- **The Root Cause:** The custom `spi_master.sv` module was incorrectly shifting the MOSI data and sampling the MISO data on *both* edges of the SPI clock cycle, causing the ADC data to be mangled and shifted out of the 12-bit register.
- **The Fix:** Rewrote the SPI State Machine to strictly adhere to the MCP3208 datasheet protocol. We now properly shift the output on the falling edge and sample the input on the rising edge, perfectly capturing all 12 bits.

### 3. Debugging the UART Sync Glitch (Values locked at 65295)
- **The Symptom:** After fixing the SPI timing, the Pico Ground Station began reporting `65295` (which is `0xFF0F` in hex).
- **The Root Cause:** A classic embedded systems startup glitch. When the Lattice FPGA boots, its floating copper pins caused the Pico UART to detect a false Start Bit and read a garbage byte. Since our telemetry packets are 2 bytes long, reading a 1-byte offset caused the Pico to permanently swap the High Byte and Low Byte!
- **The Fix:** Added a bulletproof mathematical synchronization filter into the Pico's `main.c` firmware. Because the FPGA always transmits the High Byte with four leading zeros (`0000_xxxx`), the High Byte must mathematically be strictly less than 16 (`0x10`). The Pico now instantly detects and rejects any bytes `>= 16` when looking for a High Byte, instantly self-healing the sync.

### 4. Verification
- **Perfect Telemetry:** The Pico Serial Monitor now displays a flawlessly smooth sweep from `0` to `4095` as the potentiometer is turned.
- **State Machine Simulation:** When the telemetry value sweeps past the threshold of `3500`, the Green Valve LED (pulsing at 50% PWM) instantly shuts off, and the Yellow Shutdown and Red Alarm LEDs permanently blaze on, successfully simulating a catastrophic engine failure and FADEC intervention!

### 5. Finalizing Documentation
- Wrote a new `GEMINI.md` file to enforce coding rules and preferences for all future interactions.
- Added a "Physical Hardware Integration" section to the GitHub `README.md`.
- Added a "Hardware Integration & Bug Squashing" section to the personal portfolio `fadec.html` and added the `final_breadboard.jpg` photo to showcase the build.

## Project Conclusion
The open-source FADEC architecture is officially complete and 100% functional. The system successfully demonstrates deterministic, hardware-accelerated sensor processing and telemetry generation on custom silicon, with zero OS overhead.
