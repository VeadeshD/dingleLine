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

  logic auto_rst_n;
  logic auto_start;
  logic [23:0] timer;

  // Automatically generates a reset pulse when the FPGA powers on
  reset_on_start rst_inst (
    .clk(hz100),
    .reset(auto_rst_n)
  );

  // Automatically triggers a sensor reading 10 times a second (10Hz)
  always_ff @(posedge hz100 or negedge auto_rst_n) begin
    if (!auto_rst_n) begin
      timer <= 24'd0;
      auto_start <= 1'b0;
    end else begin
      if (timer == 24'd1200000) begin
        timer <= 24'd0;
        auto_start <= 1'b1; // Trigger a 1-cycle start pulse
      end else begin
        timer <= timer + 1'b1;
        auto_start <= 1'b0;
      end
    end
  end

  sensor_pipeline my_pipe_inst(
    //inputs
    .clk        (hz100),
    .rst_n      (auto_rst_n),  // Replaced pb[0]
    .start_i    (auto_start),  // Replaced pb[1]
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
