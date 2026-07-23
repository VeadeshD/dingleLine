`timescale 1ns / 1ps

module spi_master (
    // System clock and reset
    input  logic        clk,                // System clock      
    input  logic        rst_n,              // Active-low reset
    
    // Internal FPGA signals
    input  logic        start_i,            // Trigger to start listening
    input  logic [2:0]  channel_i,          // ADC Channel to read
    output logic [11:0] data_o,             // Final sensor reading FROM ADC to FPGA
    output logic        valid_o,            // Pulses high when new reading is ready
    
    // External SPI Pins to ADC
    input  logic        spi_miso_i,         // Master In, Slave Out (Data from ADC)
    output logic        spi_sclk_o,         // Serial Clock
    output logic        spi_cs_n_o,         // Chip Select (Active Low)
    output logic        spi_mosi_o          // Master Out, Slave In (Command to ADC)
);

    // 1. Define the FSM States
    typedef enum logic [2:0] {
        IDLE       = 3'd0,
        SEND_CMD   = 3'd1,
        SAMPLE     = 3'd2,
        READ_DATA  = 3'd3,
        DONE       = 3'd4
    } state_t;

    // 2. Memory Variables (Registers/Flip-Flops)
    state_t      state_q, state_d;                 // FSM State
    logic [11:0] shift_reg_q, shift_reg_d;         // 12 bits for the ADC data
    logic [4:0]  bit_counter_q, bit_counter_d;     // To count bits 
    logic [3:0]  clk_div_q, clk_div_d;             // A 4-bit counter (counts 0 to 15) for Clock Divider
    logic        spi_clk_q, spi_clk_d;             // The actual slow clock signal     
        
    // 3. The Memory Block (Updates on Clock Edge)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q        <= IDLE; 
            shift_reg_q    <= 12'b0;
            bit_counter_q  <= 5'b0;
            clk_div_q      <= 4'b0;
            spi_clk_q      <= 1'b0;
        end else begin
            state_q        <= state_d; 
            shift_reg_q    <= shift_reg_d;
            bit_counter_q  <= bit_counter_d;
            clk_div_q      <= clk_div_d;
            spi_clk_q      <= spi_clk_d;
        end
    end

    // 4. The Decision Block (Combinational Logic)
    always_comb begin
        // 4a. Default Memory Assignments 
        state_d       = state_q;
        shift_reg_d   = shift_reg_q;
        bit_counter_d = bit_counter_q;
        clk_div_d     = clk_div_q;
        spi_clk_d     = spi_clk_q;
        
        // 4b. Clock Divider Logic
        // Run the clock divider ONLY when the FSM is busy (Not IDLE)
        if (state_q != IDLE) begin
            clk_div_d = clk_div_q + 1'b1;
            
            if (clk_div_q == 4'd5) begin
                clk_div_d = 4'b0;
                spi_clk_d = ~spi_clk_q;
            end
        end else begin 
            clk_div_d = 4'b0;
            spi_clk_d = 1'b0;     
        end
            
        // 4c. Default Output Assignments
        spi_cs_n_o = 1'b1;        // High = Chip Select Inactive
        spi_mosi_o = 1'b0;
        valid_o    = 1'b0;
        data_o     = 12'b0;
        spi_sclk_o = spi_clk_q;   // Map physical pin to our slow clock memory

        // 4d. The State Machine Logic
        case (state_q)
            IDLE: begin
                if (start_i) begin
                    state_d = SEND_CMD;
                    bit_counter_d = 5'b0;
                    
                    // MCP3208 Command: Start bit (1), Single-ended (1), plus the 3-bit channel
                    shift_reg_d = {2'b11, channel_i, 7'b0}; 
                end    
            end

            SEND_CMD: begin
                spi_cs_n_o = 1'b0;             // Wake up the ADC
                spi_mosi_o = shift_reg_q[11];  // Output top bit of shift register to ADC
                
                // Only shift data when the slow clock is about to toggle
                if (clk_div_q == 4'd5) begin
                    shift_reg_d = {shift_reg_q[10:0], 1'b0};  // Shift register left by 1                                
                    
                    if (bit_counter_q == 5'd4) begin
                        state_d = SAMPLE;
                        bit_counter_d = 5'b0; // Reset for reading phase
                    end else begin
                        bit_counter_d = bit_counter_q + 1'b1;
                    end
                end
            end

            SAMPLE: begin
                spi_cs_n_o = 1'b0; // Keep ADC awake
                
                // The ADC needs 1.5 clock cycles to physically sample the voltage.
                // We burn a cycle here to wait for the Sample-and-Hold capacitor to charge.
                if (clk_div_q == 4'd5) begin
                    state_d = READ_DATA;
                    bit_counter_d = 5'b0;
                end
            end

            READ_DATA: begin
                spi_cs_n_o = 1'b0;  // Keep ADC awake
                
                // Only read data when the slow clock is about to toggle
                if (clk_div_q == 4'd5) begin
                    // Read incoming bit from ADC and shift into bottom of register
                    shift_reg_d = {shift_reg_q[10:0], spi_miso_i};
                    
                    if (bit_counter_q == 5'd11) begin
                        state_d = DONE;
                    end else begin
                        bit_counter_d = bit_counter_q + 1'b1;
                    end
                end
            end

            DONE: begin
                spi_cs_n_o = 1'b1;        // Pull high to turn off ADC 
                valid_o    = 1'b1;        // Tell FPGA new reading is ready
                data_o     = shift_reg_q; // Output assembled 12-bit number

                state_d = IDLE;           // Go back to sleep till next trigger
            end
                
            default: state_d = IDLE;
        endcase
    end    
endmodule
