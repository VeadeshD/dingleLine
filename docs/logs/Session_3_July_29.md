# FADEC Development Log: Session 3
**Date:** July 29, 2026
**Focus:** Phase 3 - FPGA Prototyping and Physical Synthesis

## Session Summary
Following the successful completion of Phase 2 logic design and verification, today's focus shifted to physical hardware implementation. The goal was to synthesize the Verilog logic into a physical bitstream for the iCE40HX8K FPGA.

### Accomplishments
1. **Toolchain Troubleshooting:** Encountered a `GLIBC` version mismatch on the university ThinLinc server when running `verilator`. Disabled the `verilator` target in the `Makefile` as a workaround.
2. **Broken IT Environment Bypass:** Discovered the university's default `yosys` installation was missing shared libraries (`libreadline.so.8`). Bypassed the broken environment by downloading the standalone **OSS CAD Suite** release locally.
3. **Makefile Fixes:** Removed hardcoded `/home/shay/a/ece270/bin` PATH overrides in the `Makefile` to allow local toolchains to take precedence.
4. **Syntax Fixes:** Fixed a missing `end` tag in `control_laws.sv` and corrected a `pwn` to `pwm` typo in the `sensor_pipeline.sv` port list.
5. **Successful Synthesis:** Successfully ran `yosys`, `nextpnr`, and `icepack` to generate `fpga_top.bin`, confirming the FADEC logic is physically synthesizable.

### Next Steps
The physical `.bin` file is ready. The next steps will involve plugging the FPGA board into a physical machine, transferring the `.bin` file, and running `iceprog` to flash the silicon. We are also waiting on an NDA to access NanoHub for OpenLane ASIC tapeout.
