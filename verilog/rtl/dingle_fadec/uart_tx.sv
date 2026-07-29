  
  module uart_tx #(
    parameter int CLKS_PER_BIT = 104
  )(
    input logic clk,
    input logic rst_n,
    input logic tx_start_i,
    input logic [7:0] tx_data_i,
    output logic tx_o,
    output logic tx_done_o,
  );
//Define machine states
    typedef enum logic [2:0] {
      IDLE,
      START_BIT,
      DATA_BITS,
      STOP_BIT,
      CLEANUP,
    } state_t;

    
    
