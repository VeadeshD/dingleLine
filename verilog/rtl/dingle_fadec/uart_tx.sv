module fadec_uart_tx #(
    parameter int CLKS_PER_BIT = 104 //change value for needed clock speed
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
    always_comb begin
      state_d = state_q;
      clk_count_d = clk_count_q;
      bit_index_d = bit_index_q;
      tx_data_d = tx_data_q;      

      tx_o = 1'b1;
      tx_done_o = 1'b0;
      
      case(state_q) 
        IDLE: begin
          clk_count_d = 16'd0;
          bit_index_d = 3'd0;

          if(tx_start_i == 1'b1) begin
            tx_data_d = tx_data_i;
            state_d = START_BIT;
          end
        end
        START_BIT: begin
          tx_o = 1'b0;
          if(clk_count_q < CLKS_PER_BIT - 1) begin
            clk_count_d = clk_count_q + 1;
          end else begin
            clk_count_d = 1'b0;
            state_d = DATA_BITS;
          end
        end
        DATA_BITS: begin
          tx_o = tx_data_q[bit_index_q];
          if(clk_count_q < CLKS_PER_BIT - 1) begin
            clk_count_d = clk_count_q + 1;
          end else begin
            clk_count_d = 1'b0;
            if(bit_index_q < 7) begin
              bit_index_d = bit_index_q + 1;
            end else begin
              state_d = STOP_BIT;
            end
          end
        end
        STOP_BIT: begin
          tx_o = 1'b1;
          if(clk_count_q < CLKS_PER_BIT - 1) begin
            clk_count_d = clk_count_q + 1;
          end else begin        
            clk_count_d = 1'b0;
            state_d = CLEANUP;
          end
        end
        CLEANUP: begin
          tx_done_o = 1'b1;
          state_d = IDLE;
        end
      endcase
    end
endmodule
