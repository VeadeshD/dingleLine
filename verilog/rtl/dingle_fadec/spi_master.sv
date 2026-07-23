        
    module spi_master (
        //parameters here
        input logic clk,                //System clock      
        input logic rst_n,              //Active-low reset
        input logic start_i,            //Trigger to start listening
        input logic [2:0] channel_i,
        input logic spi_miso_i,
        
        output logic spi_sclk_o,
        output logic spi_cs_n_o,
        output logic spi_mosi_o,
        output logic [11:0] data_o,      //final sensor reading to ADC
        output logic valid_o            // 
    );
// Define the states
    typedef enum logic [2:0] {
        IDLE       = 3'd0,
        SEND_CMD   = 3'd1,
        SAMPLE     = 3'd2,
        READ_DATA  = 3'd3,
        DONE       = 3'd4
    } state_t;
    // Create the current state (_q) and next state (_d) variables
    state_t state_q, state_d;
    //memory variables
        logic [11:0] shift_reg_d, shift_reg_q;         //12 bits for the ADC data
        logic [4:0]  bit_counter_d, bit_counter_q;     //To count bits 
        logic [3:0] clk_div_d, clk_div_q; // A 4-bit counter (counts 0 to 15)
        logic       spi_clk_d, spi_clk_q; // The actual slow clock signal     
        
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q        <= IDLE; // If reset is pulled, go to IDLE
            shift_reg_q    <= 12'b0;
            bit_counter_q  <= 5'b0;
            clk_div_q      <= 4'b0;
            spi_clk_q      <= 1'b0;
        end else begin
            state_q        <= state_d; // Otherwise, update to the next state
            shift_reg_q    <= shift_reg_d;
            bit_counter_q  <= bit_counter_d;
            clk_div_q <= clk_div_d;
            spi_clk_q <= spi_clk_d;
        end
    end

    always_comb begin
        // 1. Default Memory Assignments (Stay the same unless told otherwise)
        state_d       = state_q;
        shift_reg_d   = shift_reg_q;
        bit_counter_d = bit_counter_q;
        spi_sclk_o = spi_clk_q;
        clk_div_d = clk_div_q;
        spi_clk_d = spi_clk_q;
        
        //clock divider memory
   
        
        //Clock divider
        //run clock only when the fsm is busy 
        if(state_q != IDLE) begin
                clk_div_d = clk_div_q + 1'b1;
                
                if(clk_div_q == 4'd5) begin
                        clk_div_d = 4'b0;
                        spi_clk_d = ~spi_clk_q;
                end
        end else begin 
            clk_div_d = 4'b0;
            spi_clk_d = 1'b0;     
        end

            
        // 2. Default Output Assignments
        spi_cs_n_o = 1'b1;  // High = Chip Select Inactive
        spi_mosi_o = 1'b0;
        valid_o    = 1'b0;
        data_o     = 12'b0;

        // 3. The State Machine
        case (state_q)
                IDLE: begin
                        if (start_i) begin
                            state_d = SEND_CMD;
                            bit_counter_d = 5'b0;
                            
                            // MCP3208 Command: Start bit (1), Single-ended (1), plus the 3-bit channel
                            // We load it into the top of our shift register
                            shift_reg_d = {2'b11, channel_i, 7'b0}; 
                        end    
                end

                SEND_CMD: begin
                        spi_cs_n_o = 1'b0;   //wake up the machine
                        spi_mosi_o = shift_reg_q[11];  //output top bit of shift register to ADC
 
                        if(clk_div_q == 4'd5) begin
                                shift_reg_d = {shift_reg_q[10:0], 1'b0};  //shift register left by 1                                
                                if (bit_counter_q == 5'd4) begin
                                        state_d = SAMPLE;
                                        bit_counter_d = 5'b0; //reset for reading phase
                                end else begin
                                        bit_counter_d = bit_counter_q + 1'b1;
                                end
                        end
                end


                SAMPLE: begin
                        spi_cs_n_o = 1'b0; // Keep ADC awake
                        // The ADC needs 1 or 2 clock cycles to physically sample the voltage.
                        // We just wait here for 1 cycle and then move to reading.
                        state_d = READ_DATA;
                        bit_counter_d = 5'b0;
                end

                READ_DATA: begin
                        spi_cs_n_o = 1'b0;  //keep ADC awake
                        //reads incoming bit from ADC and shifts into botom register

                        //count for 12 bits
                        if(clk_div_q == 4'd5) begin
                                shift_reg_d = {shift_reg_q[10:0], spi_miso_i};
                                if (bit_counter_q == 5'd11) begin
                                        state_d = DONE;
                                end else begin
                                        bit_counter_d = bit_counter_q + 1'b1;
                                end
                        end
                end

                DONE: begin
                        spi_cs_n_o = 1'b1;        //pull high to turn of ADC 
                        valid_o = 1'b1;           //Tell FGPA new reading
                        data_o = shift_reg_q;     //output matched 12 bit number

                        state_d = IDLE;           // Go back to sleep till next trigger
                end
                
                        
            default: state_d = IDLE;
        endcase
    end    
    endmodule
