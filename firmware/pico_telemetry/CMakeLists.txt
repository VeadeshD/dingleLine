# == DO NOT EDIT THE FOLLOWING LINES for the Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.3.0)
set(toolchainVersion RISCV_ZCB_RPI_2_3_0_0)
set(picotoolVersion 2.3.0)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
set(PICO_BOARD pico2 CACHE STRING "Board type")

cmake_minimum_required(VERSION 3.13)

# Initialize the Raspberry Pi Pico SDK
include(pico_sdk_import.cmake OPTIONAL)

project(pico_telemetry C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# Initialize the SDK
pico_sdk_init()

# Add the main executable
add_executable(pico_telemetry
    main.c
)

# Pull in common dependencies (stdlib for printf, hardware_uart for UART)
target_link_libraries(pico_telemetry pico_stdlib hardware_uart)

# Enable USB output, disable UART output (so printf goes to PuTTY via USB, not the hardware UART pins)
pico_enable_stdio_usb(pico_telemetry 1)
pico_enable_stdio_uart(pico_telemetry 0)

# Create the .uf2 file that we can drag-and-drop onto the Pico
pico_add_extra_outputs(pico_telemetry)
