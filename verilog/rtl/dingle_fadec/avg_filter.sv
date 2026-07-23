module avg_filter (
  input logic clk,
  input logic rst_n,
  input logic valid_i,
  input logic [11:0] data_i,

  output logic [11:0] data_o,
  output logic valid_o
);


//memory
  
//2D array of 8 12-bit numbers
  logic [11:0] buffer_d [0:7];
  logic [11:0] buffer_q [0:7];
//running sum 
  logic [14:0] sum_d, sum_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      //rest to 0
      sum_q <= 15'd0;

      //for loop to fill array
      for(int i = 0; i < 8; i++) begin
        buffer_q[i]  <= 12'b0;
      end

      end else begin
        sum_q <= sum_d;

        //use for loop to update every slot in array
        for(int i = 0; i < 8; i++) begin
          buffer_q[i] <= buffer_d[i];
        end
      end
  end

  always_comb begin
    //defaults
    sum_d = sum_q;
    //to hold memory of past data
    for(int i = 0; i < 8; i++) begin
      buffer_d[i] = buffer_q[i];
    end
    valid_o = 1'b0;
    //instant average
    data_o = sum_q[14:3];
    //calculate and add the data in properly
    if (valid_i == 1'b1) begin
        sum_d = sum_q - buffer_q[7] + data_i;
        for (int i = 7; i > 0; i--) begin
          buffer_d[i] = buffer_q[i-1];
        end
      //new data into slot 0
      buffer_d[0] = data_i;
      //tell fadec new average ready
      valid_o = 1'b1;
    end

  end
  
endmodule
  
