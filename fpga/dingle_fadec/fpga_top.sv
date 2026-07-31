`default_nettype none
// Empty top module (do not modify the ports)

module fpga_top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready,
  output logic uart_tx_o
);
  sensor_pipeline my_pipe_inst(
    //inputs
    .clk        (hz100),
    .rst_n      (pb[0]),
    .start_i    (pb[1]),
    .channel_i  (3'b000),
    .spi_miso_i (1'b0),

    //outputs
    .valve_pwm_o     (green),  // Connect to the green LED
    .alarm_o         (red),  // Connect to the red LED
    .shutdown_flag_o (blue),  // Connect to the blue LED.
    .uart_tx_o       (uart_tx_o), // Connect the UART line!

    //unused outputs
    .spi_sclk_o      (),
    .spi_cs_n_o      (),
    .spi_mosi_o      (),
    .valid_o         (),
    .data_o          ()
  );
  
    
endmodule
