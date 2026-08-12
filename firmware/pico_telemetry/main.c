#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/uart.h"

int main() {
    stdio_init_all();
    
    // Initialize the hardware UART
    uart_init(uart0, 115200);
    gpio_set_function(0, GPIO_FUNC_UART);
    gpio_set_function(1, GPIO_FUNC_UART);
    
    // Initialize the onboard LED
    const uint LED_PIN = PICO_DEFAULT_LED_PIN;
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    while (true) {
        // Toggle the LED to prove we are alive
        gpio_put(LED_PIN, !gpio_get(LED_PIN));

        if (uart_is_readable(uart0)) {
            // Read the high BYTE
            uint8_t high_byte = uart_getc(uart0);

            // BULLETPROOF SYNC FILTER:
            // Our FPGA protocol guarantees the high byte always starts with 4 zeros.
            // Therefore, the high byte MUST be mathematically less than 16 (0x10).
            // If we read a byte that is 16 or greater, we are out of sync! 
            if (high_byte >= 16) {
                continue; // Throw the garbage byte away and instantly try again!
            }

            // Wait in tiny loop until the low BYTE is available
            while (!uart_is_readable(uart0)) {
                tight_loop_contents();
            }
            // Read low BYTE
            uint8_t low_byte = uart_getc(uart0);
            
            // Reconstruct the 12-bit telemetry packet
            uint16_t telemetry_data = (high_byte & 0xFF) << 8 | low_byte;

            // Print the telemetry data to the Serial Monitor!
            printf("Telemetry Data: %u\n", telemetry_data);
        }
    }
    return 0;
}