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
  output logic [11:0] data_o

  //wire to carry data from Master to Filter
  logic raw_valid_w;
  logic [11:0] raw_data_w;

  spi_master master_inst (
    valid_o,
    raw_valid_w
    
    data_o,
    raw_data_o
);
  
