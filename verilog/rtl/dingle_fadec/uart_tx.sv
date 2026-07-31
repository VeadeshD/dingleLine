  
  module uart_tx #(
    parameter int CLKS_PER_BIT = 104
  )(
    input logic clk,
    input logic rst_n,
    input logic tx_start_i,
    input logic [7:0] tx_data_i,
    output logic tx_o,
    output logic tx_done_o
  );
//Define machine states
    typedef enum logic [2:0] {
      IDLE,
      START_BIT,
      DATA_BITS,
      STOP_BIT,
      CLEANUP
    } state_t;

    state_t state_q, state_d; 
    //memory registers
    logic [15:0] clk_count_q, clk_count_d;
    logic [2:0]  bit_index_q, bit_index_d;
    logic [7:0]  tx_data_q, tx_data_d;

    //flip-flop memory
    always_ff@(posedge clk or negedge rst_n) begin 
      if(!rst_n) begin
            state_q     <= IDLE;
            clk_count_q <= 16'd0;
            bit_index_q <= 3'd0;
            tx_data_q   <= 8'd0;
        end else begin
            state_q     <= state_d;
            clk_count_q <= clk_count_d;
            bit_index_q <= bit_index_d;
            tx_data_q   <= tx_data_d;
        end
    end
    always_comb( 
    
    
