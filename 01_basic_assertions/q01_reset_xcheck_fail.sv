module tb;

  // ------------------------------------------------------------
  // Signal declarations
  // ------------------------------------------------------------
  logic clk;
  logic rst_n;
  logic [3:0] count;
  logic [7:0] data;

  // ------------------------------------------------------------
  // Clock generation
  // Clock period = 10 ns
  // ------------------------------------------------------------
  initial clk = 0;
  always #5 clk = ~clk;

  // ------------------------------------------------------------
  // Waveform dump for EDA Playground
  // ------------------------------------------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end

  // ------------------------------------------------------------
  // Default clocking block
  // All assertions are sampled at posedge clk
  // ------------------------------------------------------------
  default clocking cb @(posedge clk);
  endclocking

  // ------------------------------------------------------------
  // Assertion 1: Count must be zero during reset
  // ------------------------------------------------------------
  // Requirement:
  // If reset is active, count must be 0.
  //
  // rst_n is active-low reset.
  // So reset active means rst_n == 0.
  //
  // |-> means overlapped implication:
  // If left side is true, right side is checked in same clock cycle.
  property p_count_zero_during_reset;
    (!rst_n) |-> (count == 4'd0);
  endproperty

  assert property (p_count_zero_during_reset)
    else $error("ASSERTION FAILED: count is not zero during reset");

  // ------------------------------------------------------------
  // Assertion 2: Data must not be unknown after reset
  // ------------------------------------------------------------
  // Requirement:
  // Once reset is released, data should not contain X or Z.
  //
  // $isunknown(data) returns 1 if data has X/Z.
  // !$isunknown(data) means data is clean.
  property p_no_unknown_data_after_reset;
    rst_n |-> !$isunknown(data);
  endproperty

  assert property (p_no_unknown_data_after_reset)
    else $error("ASSERTION FAILED: data has X/Z after reset");

  // ------------------------------------------------------------
  // Test stimulus: FAIL version
  // ------------------------------------------------------------
  initial begin
    $display("Starting FAIL version of q01_reset_xcheck");

    // ----------------------------------------------------------
    // Initial reset condition
    // This part is correct.
    // reset active, count = 0, data known.
    // ----------------------------------------------------------
    rst_n = 0;
    count = 4'd0;
    data  = 8'h00;

    repeat (2) @(posedge clk);

    // ----------------------------------------------------------
    // FAIL CASE 1:
    // Reset is still active, but count is changed to 5.
    //
    // This violates:
    // (!rst_n) |-> (count == 0)
    // ----------------------------------------------------------
    count = 4'd5;
    @(posedge clk);

    // Fix count again
    count = 4'd0;
    @(posedge clk);

    // ----------------------------------------------------------
    // Release reset
    // Now data must always be known.
    // ----------------------------------------------------------
    rst_n = 1;
    data  = 8'hAA;
    count = 4'd1;

    repeat (2) @(posedge clk);

    // ----------------------------------------------------------
    // FAIL CASE 2:
    // Reset is released, but data becomes X.
    //
    // This violates:
    // rst_n |-> !$isunknown(data)
    // ----------------------------------------------------------
    data = 8'hxx;
    @(posedge clk);

    // Fix data again
    data = 8'h55;
    repeat (2) @(posedge clk);

    $display("FAIL version completed. Assertion failures above are expected.");
    $finish;
  end

endmodule