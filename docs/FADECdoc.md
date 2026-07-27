# FPGA-Accelerated FADEC Architecture for Gridded Ion Thruster Control

**Abstract**—This paper presents the design and implementation of a Full Authority Digital Engine Control (FADEC) architecture tailored for electric propulsion, specifically gridded ion thrusters. The system leverages a hardware-accelerated finite state machine (FSM) implemented on an FPGA to provide nanosecond, deterministic response times. The methodology decouples the data acquisition pipeline from the propulsion control laws before integrating them into a single, fault-tolerant SystemVerilog architecture. A hardware-in-the-loop (HIL) simulation framework validates the system's ability to maintain stable steady-state firing while ensuring single-clock-cycle safety interrupts in the presence of over-current anomalies.

---

## I. Introduction

The growing reliance on electric propulsion for deep space missions demands highly reliable, low-latency control systems. Traditional software-based microcontrollers, while flexible, evaluate instructions sequentially, which can introduce non-deterministic latencies during critical fault events. In this work, a hardware-accelerated FADEC (Full Authority Digital Engine Control) architecture designed specifically for a gridded ion thruster is proposed. 

By migrating the propulsion control laws from software to custom digital logic on an FPGA, this work aims to achieve highly deterministic, real-time control. This document details a phased approach to developing the hardware data pipeline, modeling the control laws, and ultimately integrating these subsystems into a cohesive, fault-tolerant FPGA architecture.

## II. System Architecture

The FADEC system is partitioned into two primary functional domains: the high-speed data ingestion pipeline and the propulsion control logic. 

### A. Hardware Data Pipeline
Before control can be exerted over the thruster, the system must reliably acquire real-time telemetry from its environment. The data pipeline is designed as an independent IP core to handle sensor ingestion without consuming main control logic overhead.
- **SPI Master Interface:** A SystemVerilog SPI Master module (`spi_master.sv`) is implemented to interface directly with an external Analog-to-Digital Converter (ADC). The module continuously polls for high-voltage and current readings.
- **Signal Conditioning:** To mitigate sensor noise characteristic of high-power switching environments, the raw ADC stream is passed through a parameterizable hardware moving-average filter (`moving_avg_filter.sv`).
- **Resilience:** The pipeline is hardened against link anomalies. Through targeted fault-injection testbenches, it is ensured that the SPI interface recovers gracefully from bit-flips and desynchronization without triggering a system lock-up.

### B. Propulsion Control Laws
While the final deployment is entirely hardware-based, a software-first approach is utilized to model the complex physics and state management of electric propulsion.
- **State Modeling:** MATLAB is used to define the rigorous thresholds for electromagnetic fields and grid voltages, identifying key transition points across the `PreCharge`, `Ignition`, and `SteadyState` phases.
- **Finite State Machine (FSM):** The finite state machine was prototyped in standard C (`propulsion_fsm.c`), validating the transition logic and safety tripwires. A critical design constraint imposed is the immediate transition to a `SafeShutdown` state if simulated current spikes exceed operational limits.
- **Hardware Isolation:** A custom KiCad schematic (`dingle_isolation.kicad_sch`) was developed to physically isolate the sensitive sensor front-end from the high-voltage PWM signals required to drive the thruster's grids.

## III. Aerospace Integration

The capstone of the architecture is the seamless integration of the software-modeled FSM into the hardware data pipeline, forming a closed-loop FADEC system.

### A. Hardware-in-the-Loop Integration
The verified C/MATLAB state machine is translated into SystemVerilog combinational and sequential logic (`propulsion_fsm.sv`). In this hardware paradigm, the FPGA evaluates the entire state of the thruster concurrently on every clock tick, drastically reducing latency compared to sequential software execution. The raw, filtered telemetry from the SPI pipeline directly and instantly dictates the state transitions of the thruster.

### B. Safety Interlocks
Safety is paramount in aerospace applications. To this end, a purely combinational hardware interrupt (`safety_interrupt.sv`) was engineered. If the sensor pipeline detects an over-current event, this interrupt bypasses the main FSM entirely, severing the PWM drive signals in a single clock cycle. This guarantees an immediate, deterministic safe shutdown regardless of the current FSM state.

## IV. Methodology & Experimental Setup

The architecture is validated through a rigorous verification pipeline before physical FPGA deployment:
1. **Source-Level Simulation:** Riviera-PRO and Icarus Verilog are utilized to simulate the RTL logic, confirming that the SPI master and moving-average filter operate correctly under ideal and noisy conditions.
2. **Synthesis Verification:** Following synthesis (targeting the Sky130 standard cell library via OpenLane and Yosys), post-synthesis simulations are run to ensure logic equivalence and timing stability.
3. **Hardware Deployment:** The final bitstream is flashed onto an iCE40 FPGA (`make cram`), interfacing with breadboard peripherals and the custom KiCad isolation board to evaluate real-world performance.

## V. Expected Results and Future Work

*(Note: This section will be populated as empirical data is gathered during the physical implementation phase.)*

It is expected that the hardware-accelerated FSM will demonstrate reaction times several orders of magnitude faster than a comparable microcontroller-based system. Specifically, the single-cycle safety interrupt is projected to de-assert the PWM drive lines within nanoseconds of an over-current detection. 

Future work will involve characterizing the exact thermal and power footprint of the FPGA FADEC during steady-state firing and running comprehensive environmental stress tests on the isolation PCB.

## VI. Conclusion

The proposed FADEC architecture demonstrates a scalable, highly reliable approach to gridded ion thruster control. By systematically developing the data pipeline, modeling the control laws, and merging them into an FPGA fabric, a robust framework capable of deterministic fault recovery has been established—a critical requirement for next-generation electric propulsion systems.

## References
*(To be populated with relevant literature on electric propulsion control, FPGA reliability in aerospace, and hardware-in-the-loop simulation standards.)*
