`default_nettype none

// Muliplication Coprocessor Testbench
module Multiplier_test;
  logic               start, reset, clock;
  logic signed [7:0]  a, b;
  logic               done;
  logic        [1:0]  ZN_flags;  
  logic signed [15:0] out;

  // Generate clock signal
  initial begin
    clock = 0;
    forever #5 clock = ~ clock ;
  end

  Multiplier dut (.*);

  initial begin
    $monitor ($time,, {"start=%b, reset=%b, a=%d, b=%d, out=%d, ",
              "done=%b, ZN_flags=%b"}, 
              start, reset, a, b, out, done, ZN_flags);

    $display("Testing Multiplier...");

    // initialize values
    reset <= 1'b1;

    @(posedge clock);
    @(posedge clock);

    reset <= 1'b0;

    // Test 5 random multiplication problems where a and b are 
    // within [-128, 127] inclusive

    $display("Testing 5 random multiplication problems...");

    // Test 3 * 4 = 12
    a <= 8'sd3;
    b <= 8'sd4;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    // Test 12 * 5 = 60
    a <= 8'sd12;
    b <= 8'sd5;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    // Test -7 * 10 = -70
    a <= -8'sd7;
    b <= 8'sd10;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    // Test 20 * -4 = -80
    a <= 8'sd20;
    b <= -8'sd4;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    // Test -15 * -3 = 45
    a <= -8'sd15;
    b <= -8'sd3;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    $display("Testing edge cases...");

    // Test -128 * 0 = 0
    a <= -8'sd128;
    b <= 8'sd0;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");
    
    // Test 1 * -128 = -128
    a <= 8'sd1;
    b <= -8'sd128;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    // Test -128 * -1 = 128
    a <= -8'sd128;
    b <= -8'sd1;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    // Test -128 * -128 = 16384
    a <= -8'sd128;
    b <= -8'sd128;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    // Test 127 * 127 = 16129
    a <= 8'sd127;
    b <= 8'sd127;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    // Test -128 * 127 = -16256
    a <= -8'sd128;
    b <= 8'sd127;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    // Test 127 * -128 = -16256
    a <= 8'sd127;
    b <= -8'sd128;
    start <= 1'b1;
    @(posedge clock);
    start <= 1'b0;
    
    wait(done == 1'b1);
    @(posedge clock);

    $display("*********************************************");

    #1 $finish;

  end

endmodule : Multiplier_test