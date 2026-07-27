
module tb_control_laws();

  //fake wires
  logic        clk;
  logic        rst_n;
  logic        valid_i;
  logic [11:0] data_i;
  logic        valve_pwm_o;
  logic        alarm_o;
  logic        shutdown_flag_o;

  //the DUT(device under test)
  control_laws DUT(
    .clk(clk),
    .rst_n(rst_n),
    .valid_i(valid_i),
    .data_i(data_i),
    .valve_pwm_o(valve_pwm_o),
    .alarm_o(alarm_o),
    .shutdown_flag_o(shutdown_flag_o)
  );

  //fake clock
  initial begin
    clk = 1'b0;
  end
  always #41.66 clk = ~clk;

  //test sequence
  initial begin
    $dumpfile("tb_control_laws.vcd");
    $dumpvars(0, tb_control_laws);

    //start w reset pushed
    rst_n = 1'b0;
    valid_i = 1'b0;
    data_i = 12'd0;

    #100;

    //let go of reset

    rst_n = 1'b1;
    #100;

    // --- TEST 1: NOMINAL FLIGHT ---
    //inject valid reading
    valid_i = 1'b1;
    data_i = 12'd2048;

    //wait
    #25000;


    // --- TEST 2: CATASTROPHIC FAILURE ---
    data_i = 12'd4000;

    #1000;

    $finish;
  end
endmodule

