module control_laws (
  input logic clk,
  input logic rst_n,
  input logic valid_i,
  input logic [11:0] data_i,

  output logic  valve_pwm_o, //valve for pulse width modulation
  output logic  alarm_o,
  output logic  shutdown_flag_o
);
  
  typedef enum logic [1:0]{
    STARTUP,
    STEADY_STATE,
    EMERGENCY_SHUTDOWN
  }  fadec_state_t;
  
  fadec_state_t state_q, next_state_d;

  logic [7:0] pwm_counter_q;
  
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state_q <= STARTUP;
    end else begin
      state_q <= next_state_d;
    end
  end

  always_comb begin
    next_state_d = state_q;

    case(state_q)
      STARTUP: begin
        if(valid_i == 1'b1) begin
          next_state_d = STEADY_STATE;
        end
      end
      STEADY_STATE: begin
        if(valid_i == 1'b1 && data_i > 12'd3500) begin
          next_state_d = EMERGENCY_SHUTDOWN;
        end
      end
      EMERGENCY_SHUTDOWN: begin
      end

      default: next_state_d = STARTUP;
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      //when button pressed turn everything off
      pwm_counter_q <= 8'd0;
      valve_pwm_o <= 1'b0;
      shutdown_flag_o <= 1'b0;
      alarm_o <= 1'b0;

    end else begin
      //the counter must always count up to keep pwm pulsing
      pwm_counter_q <= pwm_counter_q + 1'b1;

      case(state_q)
        STARTUP: begin
          valve_pwm_o <= 1'b0;
          alarm_o <= 1'b0;
        end

        STEADY_STATE: begin
          //create a 50% DUTY cycle PWM wave(on if the counter is less than 255)
          if(pwm_counter_q < 8'd128) begin
              valve_pwm_o <= 1'b1;
          end else begin
            valve_pwm_o <=1'b0;
          end
        end

        EMERGENCY_SHUTDOWN: begin
          //shut off and sound alarm
          valve_pwm_o <= 1'b0;
          alarm_o <= 1'b1;
          shutdown_flag_o <= 1'b1;
        end
      endcase

    end
  
  endmodule
              
  
