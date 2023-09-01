
ECE 4750 Section 2: RTL Design with Verilog
==========================================================================

 - Author: Aidan C. McNay and Cecilio C. Tamarit
 - Date: August 31, 2023
 - Loosely based on previous ECE 4750 material from Christopher Batten

**Table of Contents**

 - Verilog RTL for a latency-insensitive adder
 - Verilator crash course
 - The Perpetual Testing Initiative
 - When all else fails

This discussion section serves as gentle introduction to our
Verilog RTL design and testing flow. For an in-depth Verilog guide,
we recommend reading [our Verilog tutorial] or [HDLBits]. 

Let's start by logging into the `ecelinux` servers using the remote 
access option of your choice. Then, source the setup script and download
our sample project.

    % source setup-ece4750.sh
    % mkdir -p $HOME/ece4750/sec
    % cd $HOME/ece4750/sec
    % wget
    % cd sec02
    % TOPDIR=$PWD

Verilog RTL for a latency-insensitive adder
--------------------------------------------------------------------------

We will start by implementing a simple single-cycle multiplier. Whenever
implementing hardware, we always like to start with some kind of diagram. It
could be a block diagram, datapath diagram, or finite-state-machine
diagram. Here is a block diagram for our latency-insensitive adder. Notice
how we are using registered inputs. In this course, if we want to include
registers in a block we usually prefer registered inputs instead of
registered outputs.

![](assets/fig/tb_Adder.png)

Here is the interface for our latency-insensitive adder.

    module imul_IntMulScycleV1
    (
      input  logic        clk,
      input  logic        reset,

      input  logic [31:0] in0,
      input  logic [31:0] in1,
      output logic [31:0] out
    );

Our single-cycle multiplier takes two 32-bit input values and produces a
32-bit output value. Notice our coding conventions. We prefix all Verilog
module names with the corresponding directory path, we use CamelCase for
Verilog module names, and we align all port names. We can implement this
single-cycle multiplier flat (i.e., directly use behavioral modeling
without instantiating any child modules) or structurally (i.e.,
instantiate child modules). Here is what a flat implementation might look
like:

    //----------------------------------------------------------------------
    // Input Registers (sequential logic)
    //----------------------------------------------------------------------

    logic [31:0] in0_reg;
    logic [31:0] in1_reg;

    always @( posedge clk ) begin
      if ( reset ) begin
        in0_reg <= 32'b0;
        in1_reg <= 32'b0;
      end
      else begin
        in0_reg <= in0;
        in1_reg <= in1;
      end
    end

    //----------------------------------------------------------------------
    // Multiplication Logic (combinational logic)
    //----------------------------------------------------------------------

    always @(*) begin
      out = in0_reg * in1_reg;
    end

Note that we are using an `always @(posedge clk)` to model sequential
logic and an `always @(*)` to model combinational logic. Always be very
explicit about what part of your design is sequential and what part is
combinational. **Always** use non-blocking assignments (`<=`) in an
`always @(posedge clk)` and **always** use blocking assignments (`=`) in
an `always @(*)`. At least when getting started, try to avoid including
too much combinational logic in your sequential blocks. You can also
include simple combinational logic directly in an `assign` statement. So
we could replace the `always @(*)` with the following:


