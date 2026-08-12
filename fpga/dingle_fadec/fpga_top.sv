`default_nettype none
// Empty top module (do not modify the ports)

module fpga_top (
  input  logic hwclk,
  output logic [7:0] onboard_leds,
  output logic uart_tx_o,
  
  // SPI Interface to MCP3208
  input  logic spi_miso,
  output logic spi_mosi,
  output logic spi_sclk,
  output logic spi_cs_n,

  // External FADEC LEDs
  output logic ext_valve_o,
  output logic ext_alarm_o,
  output logic ext_shutdown_o
);

  logic auto_rst_n;
  logic auto_start;
  logic [23:0] timer;
  logic [23:0] heartbeat_timer;
  logic heartbeat_led;

  // Automatically generates a reset pulse when the FPGA powers on
  reset_on_start rst_inst (
    .clk(hwclk),
    .reset(auto_rst_n)
  );

  // Automatically triggers a sensor reading 10 times a second (10Hz)
  // And flashes a heartbeat LED every second
  always_ff @(posedge hwclk or negedge auto_rst_n) begin
    if (!auto_rst_n) begin
      timer <= 24'd0;
      auto_start <= 1'b0;
      heartbeat_timer <= 24'd0;
      heartbeat_led <= 1'b0;
    end else begin
      // 10Hz Trigger
      if (timer == 24'd1200000) begin
        timer <= 24'd0;
        auto_start <= 1'b1; // Trigger a 1-cycle start pulse
      end else begin
        timer <= timer + 1'b1;
        auto_start <= 1'b0;
      end
      
      // 1Hz Heartbeat LED
      if (heartbeat_timer == 24'd6000000) begin
        heartbeat_timer <= 24'd0;
        heartbeat_led <= ~heartbeat_led;
      end else begin
        heartbeat_timer <= heartbeat_timer + 1'b1;
      end
    end
  end

  sensor_pipeline my_pipe_inst(
    //inputs
    .clk        (hwclk),
    .rst_n      (auto_rst_n),
    .start_i    (auto_start),
    .channel_i  (3'b000),
    .spi_miso_i (spi_miso),  // Now connected to physical pin!

    //outputs
    .valve_pwm_o     (ext_valve_o),
    .alarm_o         (ext_alarm_o),
    .shutdown_flag_o (ext_shutdown_o),
    .uart_tx_o       (uart_tx_o),

    // SPI outputs
    .spi_sclk_o      (spi_sclk),
    .spi_cs_n_o      (spi_cs_n),
    .spi_mosi_o      (spi_mosi),
    .valid_o         (),
    .data_o          ()
  );
  
  // Assign heartbeat to all 8 onboard LEDs!
  assign onboard_leds = {8{heartbeat_led}};
  
endmodule

module reset_on_start (
  input  logic clk,
  output logic reset
);
  logic [3:0] reset_cnt = 0;
  always_ff @(posedge clk) begin
    if (reset_cnt != 4'hf) reset_cnt <= reset_cnt + 1;
  end
  assign reset = (reset_cnt == 4'hf);
endmodule
