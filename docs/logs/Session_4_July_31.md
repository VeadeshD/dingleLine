# Session 4: July 31, 2026 - UART Telemetry & Autonomous Execution

## Goals
- Complete the UART transmitter integration so the FADEC can stream 12-bit telemetry to a Ground Station.
- Successfully flash the Lattice iCE40HX8K Breakout Board.
- Establish a live PuTTY serial connection to view the datastream.

## Tasks Completed

### 1. Flashing the Bitstream
- Re-installed the generic `WinUSB` driver for the Lattice board (Interface 0) using Zadig because Windows Update had overwritten it.
- Bypassed the broken legacy `build.bat` script by manually running the `iceprog` command inside the `oss-cad-suite` environment.
- Flashed the `fpga_top.bin` bitstream successfully to the FPGA.

### 2. UART Integration Debugging
- **Missing Wire:** Discovered that the `uart_tx_o` port was left completely unconnected in the `fpga_top.sv` wrapper. The synthesizer was aggressively optimizing away our entire UART state machine to save space because the output went nowhere. Added the port and wired it up.
- **Syntax Error:** Fixed a missing `endmodule` keyword at the end of `uart_tx.sv` that was causing `unexpected end of file` during Yosys synthesis.
- **Module Name Collision:** Encountered a `Re-definition of module \uart_tx` error because the university's starter code (`support/fpga/uart_tx.v` from the Battleship project) contained a module with the exact same name. Renamed our new UART module to `fadec_uart_tx` in both `uart_tx.sv` and `sensor_pipeline.sv`.

### 3. Autonomous Execution Refactor
- Realized that because we are using the raw green Lattice Breakout Board instead of the full Purdue ECE270 Baseboard, we do not have physical pushbuttons to trigger the FADEC!
- **Floating Pins:** Because `pb[0]` (reset) and `pb[1]` (start) were floating, the SPI master was completely dead.
- **Auto-Reset:** Imported the `reset_on_start` module to generate a proper `rst_n` pulse when the FPGA powers on.
- **10Hz Auto-Trigger:** Wrote a 24-bit counter inside `fpga_top.sv` that generates a 1-cycle `start_i` pulse every 1,200,000 clock cycles (10 times a second at 12MHz). The FADEC now autonomously streams telemetry without needing any user intervention.

### 4. Verification
- Compiled successfully with Yosys/NextPNR.
- Connected via PuTTY (COM4, 115200 baud).
- Because the SPI `miso` pin is currently hardcoded to `1'b0` (since we are waiting for the MCP3208 ADC chip to arrive in the mail), the FPGA successfully streamed `0x00` (NUL) bytes to PuTTY. 

## Next Steps
- When the MCP3208 ADC chip arrives, plug it into the breadboard using Male-to-Male jumper wires.
- Write bare-metal C/C++ firmware for the Raspberry Pi Pico 2 (RP2350) to ingest the UART byte stream, reconstruct the 12-bit sensor data, and print the live telemetry values to the computer over USB.
