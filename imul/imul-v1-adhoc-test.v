//========================================================================
// Integer Multiplier V1 Ad-Hoc Testing
//========================================================================

`include "imul/IntMulScycleV1.v"

module top;

  // Clocking

  logic clk = 1;
  always #5 clk = ~clk;

  // Instaniate the design under test

  logic        reset = 1;
  logic [31:0] in0;
  logic [31:0] in1;
  logic [31:0] out;

  // Instantiate the multiplier

  imul_IntMulScycleV1 imul
  (
    .clk   (clk),
    .reset (reset),
    .in0   (in0),
    .in1   (in1),
    .out   (out)
  );

  // Simulate the integer multiplier

  initial begin

    // Dump waveforms

    $dumpfile("imul-v1-adhoc-test.vcd");
    $dumpvars;

    // Reset

    #11;
    reset = 1'b0;

    // Cycle 1

    in0 = 32'h02;
    in1 = 32'h03;
    #10;
    $display( " cycle = 1: in0 = %x, in1 = %x, out = %x", in0, in1, out );

    // Cycle 2

    in0 = 32'h05;
    in1 = 32'h05;
    #10;
    $display( " cycle = 2: in0 = %x, in1 = %x, out = %x", in0, in1, out );

    // Cycle 3

    in0 = 32'h10;
    in1 = 32'h02;
    #10;
    $display( " cycle = 3: in0 = %x, in1 = %x, out = %x", in0, in1, out );

    // Cycle 4

    in0 = 32'h0f;
    in1 = 32'h01;
    #10;
    $display( " cycle = 4: in0 = %x, in1 = %x, out = %x", in0, in1, out );

    $finish;
  end

endmodule

