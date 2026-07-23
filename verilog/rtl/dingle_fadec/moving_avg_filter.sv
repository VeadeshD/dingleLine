`timescale 1ns / 1ps

module moving_avg_filter (
  input  logic        clk,
  input  logic        rst_n,
  input  logic        valid_i,
  input  logic [11:0] data_i,

  output logic [11:0] data_o,
  output logic        valid_o
);

  // 1. The Memory (The Rolling Buffer)
  logic [11:0] buffer_d [0:7];
  logic [11:0] buffer_q [0:7];
  
  // The running sum: 15 bits wide to prevent overflow
  logic [14:0] sum_d, sum_q;

  // 2. The Memory Block (Updates on Clock Edge)
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      // Reset to 0
      sum_q <= 15'd0;

      // Use a for loop to reset every slot in the array
      for(int i = 0; i < 8; i++) begin
        buffer_q[i] <= 12'b0;
      end
    end else begin
      sum_q <= sum_d;

      // Use a for loop to update every slot in the array
      for(int i = 0; i < 8; i++) begin
        buffer_q[i] <= buffer_d[i];
      end
    end
  end

  // 3. The Decision Block (Math and Shifting)
  always_comb begin
    // Defaults: Hold memory steady unless valid_i triggers
    sum_d = sum_q;
    for(int i = 0; i < 8; i++) begin
      buffer_d[i] = buffer_q[i];
    end
    
    valid_o = 1'b0;
    
    // Output the instantly calculated average (Divide by 8 trick)
    data_o = sum_q[14:3];
    
    // The Math Trigger
    if (valid_i == 1'b1) begin
        // Calculate the new sum instantly
        sum_d = sum_q - buffer_q[7] + data_i;
        
        // Shift all the old data over in the array
        for (int i = 7; i > 0; i--) begin
          buffer_d[i] = buffer_q[i-1];
        end
        
        // Put the brand new data into slot 0
        buffer_d[0] = data_i;
        
        // Tell the FADEC safety logic that a new average is ready!
        valid_o = 1'b1;
    end
  end
  
endmodule
