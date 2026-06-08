module tb; 
  logic clk, rst_n,
  logic [3:0] count,
  logic [7:0] data;

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin 
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end 

  default clocking cb @(posedge clk);
  endclocking

  property p_count_zero_during_reset;
    (!rst_n) |-> (count == 4'd0);
  endproperty

  assert property(p_count_zero_during_reset)
  else $error("Assertion Failed: count is not zero during reset");

  ////////////////////////////////////////////////////

  property p_unkown_data_after_reset;
    rst_n |-> !$isunkown(data);
  endproperty

  assert property(p_unkown_data_after_reset)
  else $error("Assertion Failed: data has x or z after reset")

  ///////////////////////////////////////////////////
  initial begin 
    $display("Starting PASS Version of q01");

    // ----------------------------------------------------------
    // Initial reset phase
    // ----------------------------------------------------------
    // Reset is active because rst_n = 0.
    // During this time, count is kept 0.
    // So Assertion 1 should pass.
    //
    // data is also initialized to known value 00.
    rst_n = 0;
    count = 4'd0;
    data  = 8'h00;

    // Wait for 3 positive clock edges.
    // Assertions are checked at each posedge clk.
    repeat (3) @(posedge clk);

    // ----------------------------------------------------------
    // Reset release
    // ----------------------------------------------------------
    // rst_n = 1 means reset is released.
    // Now data should not be X/Z.
    //
    // data = 8'hAA is a known value.
    // So Assertion 2 should pass.
    rst_n = 1;
    data  = 8'hAA;
    count = 4'd1;

    // Wait for 5 clock cycles.
    repeat (5) @(posedge clk);

    // ----------------------------------------------------------
    // Normal operation after reset
    // ----------------------------------------------------------
    // data is changed to another known value.
    // count is changed to another value.
    //
    // Since reset is released, count does not need to be 0 anymore.
    // Assertion 1 only checks count when reset is active.
    //
    // data is still known, so Assertion 2 should pass.
    data  = 8'h55;
    count = 4'd2;

    // Wait for 3 more clock cycles.
    repeat (3) @(posedge clk);

    // If simulation reaches here without assertion error,
    // both assertions passed successfully.
    $display("PASS: Simulation completed without assertion failure");

    // End simulation.
    $finish;
  end

endmodule 