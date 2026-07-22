        
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
        
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q        <= IDLE; // If reset is pulled, go to IDLE
            shift_reg_q    <= 12'b0;
            bit_counter_q  <= 5'b0;
        end else begin
            state_q        <= state_d; // Otherwise, update to the next state
            shift_reg_q    <= shift_reg_d;
            bit_counter_q  <= bit_counter_d; 
        end
    end

    always_comb begin
        // 1. Default Memory Assignments (Stay the same unless told otherwise)
        state_d       = state_q;
        shift_reg_d   = shift_reg_q;
        bit_counter_d = bit_counter_q;
        
        // 2. Default Output Assignments
        spi_cs_n_o = 1'b1;  // High = Chip Select Inactive
        spi_sclk_o = 1'b0;  // Clock starts low
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
            
            // ... (We will write SEND_CMD and READ_DATA next!)
            
            default: state_d = IDLE;
        endcase
    end    
    endmodule
