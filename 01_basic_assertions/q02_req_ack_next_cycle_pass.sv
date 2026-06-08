module tb;
    logic clk, rst_n, req, ack;

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

    default clocking cb @(posedge clk);
    endclocking

    property az;
        $rose(req) |=> ack;
    endproperty

    assert property(az)
    else $error("Assertion Failed: ack not high when req rose high");

 initial begin
    $display("Starting PASS version of q02_req_ack_next_cycle");

    // Initial values
    rst_n = 0;
    req   = 0;
    ack   = 0;

    // Wait for 2 clock cycles in reset
    repeat (2) @(posedge clk);

    // Release reset
    rst_n = 1;
    @(posedge clk);

    // ----------------------------------------------------------
    // FAIL CASE 1:
    // req rises in this cycle.
    // ack becomes high in the next cycle.
    // ----------------------------------------------------------
    req = 1;
    ack = 0;
    @(posedge clk);

    req = 0;
    ack = 0;
    @(posedge clk);

    ack = 0;
    repeat (2) @(posedge clk);

    // ----------------------------------------------------------
    // PASS CASE 2:
    // Another req rise.
    // Again ack comes in the next cycle.
    // ----------------------------------------------------------
    req = 1;
    ack = 0;
    @(posedge clk);

    req = 0;
    ack = 1;
    @(posedge clk);

    ack = 0;
    repeat (2) @(posedge clk);

    $display("PASS: q02 completed without assertion failure");
    $finish;
  end

endmodule