module tb_sensor_pipeline();

  logic  clk;
  logic  rst_n;
  logic start_i;
  logic [2:0] channel_i;
  logic spi_miso_i;
  logic spi_sclk_o;
  logic spi_cs_n_o;
  logic spi_mosi_o;
  logic valid_o;
  logic [11:0] data_o;

  //DUT
  sensor_pipeline DUT (
    .clk        (clk),
    .rst_n      (rst_n),
    .start_i    (start_i),
    .channel_i  (channel_i),
    
    // ADC Pins
    .spi_miso_i (spi_miso_i),
    .spi_sclk_o (spi_sclk_o),
    .spi_cs_n_o (spi_cs_n_o),
    .spi_mosi_o (spi_mosi_o),
    .valid_o    (valid_o),
    .data_o     (data_o)
    
  );

  //Fake clock
  initial begin
    clk = 1'b0;
  end

  //Flip the clock every 41.6 nanoseconds to achieve one half of a full clock cycle
  always #41.66 clk = ~clk;

  initial begin
    $dumpfile("tb_sensor_pipeline.vcd");
    $dumpvars(0, tb_sensor_pipeline);

    //initial state
    rst_n = 1'b0;
    start_i = 1'b0;
    channel_i = 3'b011; //random chanel
    spi_miso_i = 1'b0;  //keep miso silent for now
    #100;
    
    //let go of reset
    rst_n = 1'b1;
    #100;
    
    //press start
    start_i = 1'b1;
    #100;

    //let go of start
    start_i = 1'b0;
    //Wait for spi master to do math
    #50000;

    //End
    $finish;
  end

  

    
    
    
    
    
    
  
endmodule  
