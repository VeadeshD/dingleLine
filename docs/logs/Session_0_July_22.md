# Engineering Log: Session 0 (Project Kickoff)
**Date:** July 22, 2026
**Engineer:** Veadesh
**Focus:** Project Scaffolding and Documentation Standardization

## Work Accomplished
Today's session served as the formal kickoff for the FADEC project. The primary goal was to establish a clean repository and set up a professional documentation framework before diving into RTL development.

1. **Repository Cleanup**: 
   - Cleared out legacy `Battleship` code (`shipPlacement.sv`).
   - Removed old simulation logs and legacy top-level modules (`reset.sv`, `top.sv`).
   - Cleaned up `.gitignore` to ensure build artifacts are not pushed to version control.
2. **Project Scaffolding**: 
   - Executed the `make setup_dingle_fadec` command to scaffold the OpenLane/Sky130 directory structure.
   - Updated the `PROJECT` variable in the Makefile to target the new FADEC design.
3. **Documentation Standardization**:
   - Rewrote `docs/ROADMAP.md` to reflect a 3-phase implementation plan.
   - Transitioned all documentation to a professional, first-person perspective.
   - Initialized `docs/dingle_fadec/info.md` to serve as the Efabless tapeout datasheet.
4. **Academic Integration**:
   - Created `docs/IEEE_Paper_Draft.md`. This document will serve as a living draft for an eventual IEEE Aerospace Conference submission, outlining the FADEC system architecture in a formal academic format.

## Key Decisions
- **Target Hardware**: The initial prototyping and verification will target the Lattice iCE40 FPGA, with the ultimate goal of an ASIC tapeout via the Sky130 PDK.
- **Sensor Choice**: Validated the use of the MCP3208 SPI ADC for reading analog telemetry (voltage/current) from the ion thruster grid.

## Next Session Goals
- Begin Phase 1 (Hardware Data Pipeline).
- Design and implement the `spi_master.sv` module to interface with the MCP3208.
