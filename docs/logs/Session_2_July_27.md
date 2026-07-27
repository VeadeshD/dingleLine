# FADEC Development Log: Session 2
**Date:** July 27, 2026
**Focus:** Phase 2 - Propulsion Control Laws (Safety FSM & PWM)

## Session Summary
Today, I engineered the "Brain" of the FADEC: the Propulsion Control Laws module. My goal was to create a deterministic hardware module that could take the clean telemetry from Phase 1, evaluate it against hard-coded safety redlines, and physically control the fuel valves using a digital PWM signal.

## Accomplishments
1. **Engineered the Safety FSM:**
   - I successfully mapped out and built a 3-state Finite State Machine (`STARTUP`, `STEADY_STATE`, `EMERGENCY_SHUTDOWN`).
   - I separated the combinational logic (next state evaluation) from the sequential memory (flip-flops) to adhere to strict aerospace coding standards.
   - The FSM actively checks the telemetry against a redline threshold (`12'd3500`), guaranteeing an irreversible trip into the shutdown state if exceeded.

2. **Built a Hardware PWM Controller:**
   - I implemented an 8-bit counter that increments 12 million times a second on the rising edge of the system clock.
   - Using this counter, I created a 50% duty cycle PWM square wave (`if (pwm_counter_q < 8'd128)`) to physically hover the Xenon gas valve at exactly 50% open during steady-state flight.

3. **Top-Level Integration & Verification:**
   - I wired the `control_laws.sv` module into my `sensor_pipeline.sv` top-level wrapper, successfully mapping the pipeline's data stream directly into the FSM's brain.
   - I wrote a dedicated testbench (`tb_control_laws.sv`) and simulated the system in EDA Playground.
   - *Verification Success:* The EPWave results perfectly demonstrated the FSM switching to `STEADY_STATE` upon receiving nominal data, and instantly slamming into `EMERGENCY_SHUTDOWN` (flatlining the PWM valve and asserting the alarm pin) exactly when the injected data spiked to `4000`.

## Obstacles Overcome
- I ran into several classic SystemVerilog syntax pitfalls (missing semicolons, incorrect `begin`/`end` blocks, and confusing the blocking `=` with the non-blocking `<=`). However, I learned the critical rule of flip-flops (always use `<=`) and how to correctly close my blocks to appease the Icarus Verilog compiler.

## Next Steps
Phase 2 is officially complete! My next goal is Phase 3: Synthesis. I am ready to set up my toolchain, write the Physical Constraints File (.pcf) to map my I/O ports to the physical pins on my iCE40 FPGA, and flash the bitstream into silicon!
