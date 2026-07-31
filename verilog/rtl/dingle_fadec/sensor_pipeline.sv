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
  output logic shutdown_flag_o,

  //UART Output
  output logic uart_tx_o
);
  
  //wire to carry data from Master to Filter
  logic raw_valid_w;
  logic [11:0] raw_data_w;

  //UART internal wires
  logic tx_start_w;
  logic [7:0] tx_data_w;
  logic tx_done_w;
  
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

  fadec_uart_tx #(
    .CLKS_PER_BIT(104)   
  )
  telemetry_uart (
    .clk        (clk),
    .rst_n      (rst_n),
    .tx_start_i (tx_start_w),
    .tx_data_i  (tx_data_w),
    .tx_o       (uart_tx_o),
    .tx_done_o  (tx_done_w)
  );

  typedef enum logic [2:0] {
    T_IDLE,
    T_BYTE1,
    T_WAIT1,
    T_BYTE2,
    T_WAIT2
  } t_state_t;

  t_state_t t_state_q, t_state_d;
  logic [11:0] t_data_q, t_data_d;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      t_state_q <= T_IDLE;
      t_data_q <= 12'b0;
    end else begin
      t_state_q <= t_state_d;
      t_data_q <= t_data_d;
    end
  end
    
  always_comb begin
      t_state_d = t_state_q;
      t_data_d = t_data_q;
    
      tx_start_w = 1'b0;
      tx_data_w  = 8'd0;
      case (t_state_q)
        T_IDLE: begin
          if(valid_o == 1'b1) begin
            t_data_d = data_o;
            t_state_d = T_BYTE1;
          end
        end
        T_BYTE1: begin
          tx_data_w = {4'b0000, t_data_q[11:8]};
          tx_start_w = 1'b1;
          t_state_d = T_WAIT1;
        end
        T_WAIT1: begin
          if(tx_done_w == 1'b1) begin
            t_state_d = T_BYTE2;
          end
        end
        T_BYTE2: begin
          tx_data_w = t_data_q[7:0];
          tx_start_w = 1'b1;
          t_state_d = T_WAIT2;
        end
        T_WAIT2: begin
          if(tx_done_w == 1'b1) begin
            t_state_d = T_IDLE;
          end
        end
      endcase
  end
                       
endmodule
  
