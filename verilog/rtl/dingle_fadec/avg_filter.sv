module avg_filter (
  input logic clk,
  input logic rst_n,
  input logic valid_i,
  input logic [11:0] data_i,

  output logic [11:0] data_o,
  output logic valid_o,
);


//memory
  
//2D array of 8 12-bit numbers
  logic [11:0] buffer_d [0:7];
  logic [11:0] buffer_q [0:7];
//running sum 
  logic [14:0] sum_d, sum_q;

  always_ff(posedge clk or negedge clk) begin
    if(!rst_n) begin
      //rest to 0
      sum_q = 15'd0
    
  

  
endmodule
  
