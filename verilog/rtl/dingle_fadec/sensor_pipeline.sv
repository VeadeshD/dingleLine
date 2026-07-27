//Top level module

module sensor_pipeline (
  input logic clk,
  input logic rst_n,
  
  //FADEC Control 
  input logic start_i,
  input logic [2:0] channel_i,
  input logic spi_miso_i,

  output logic spi_sclk_o,
  output logic spi_cs_n_o,
  output logic spi_mosi_o,

  //FADEC Outputs
  output logic valid_o,
  output logic [11:0] data_o,
  output logic valve_pwm_o,
  output logic alarm_o,
  output logic shutdown_flag_o
);
  
  //wire to carry data from Master to Filter
  logic raw_valid_w;
  logic [11:0] raw_data_w;
  spi_master master_inst (
  
    .clk        (clk),
    .rst_n      (rst_n),
    .start_i    (start_i),
    .channel_i  (channel_i),
    
    // ADC Pins
    .spi_miso_i (spi_miso_i),
    .spi_sclk_o (spi_sclk_o),
    .spi_cs_n_o (spi_cs_n_o),
    .spi_mosi_o (spi_mosi_o),
    
    // Output to Filter (using our internal wires!)
    .valid_o    (raw_valid_w),
    .data_o     (raw_data_w)
  );

  avg_filter filter_inst (
    
    .clk        (clk),
    .rst_n      (rst_n),
    .valid_i    (raw_valid_w),
    .data_i     (raw_data_w),
    
    // Output to Filter (using our internal wires!)
    .valid_o    (valid_o),
    .data_o     (data_o)    
  );

  control_laws brain_inst (
    .clk              (clk),
    .rst_n            (rst_n),
    .valid_i          (valid_o),
    .data_i           (data_o),
    .valve_pwm_o      (valve_pwm_o),
    .alarm_o          (alarm_o),
    .shutdown_flag_o  (shutdown_flag_o)
  );    
  
endmodule
  
