//========================================================================
// Integer Multiplier Single Cycle Implementation
//========================================================================

`ifndef IMUL_INT_MUL_SCYCLE_V1_V
`define IMUL_INT_MUL_SCYCLE_V1_V

`include "vc/trace.v"
`include "vc/regs.v"

module imul_IntMulScycleV1
(
  input  logic        clk,
  input  logic        reset,

  input  logic [31:0] in0,
  input  logic [31:0] in1,
  output logic [31:0] out
);

  //----------------------------------------------------------------------
  // Input Registers (sequential logic)
  //----------------------------------------------------------------------
  // Implement the two input registers below.

  //----------------------------------------------------------------------
  // Multiplication Logic (combinational logic)
  //----------------------------------------------------------------------
  // Implement the multiplication logic below.

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x|%x", in0, in1 );
    vc_trace.append_str( trace_str, str );

    vc_trace.append_str( trace_str, "(" );

    $sformat( str, "%x", in0_reg );
    vc_trace.append_str( trace_str, str );
    vc_trace.append_str( trace_str, " " );

    $sformat( str, "%x", in1_reg );
    vc_trace.append_str( trace_str, str );

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", out );
    vc_trace.append_str( trace_str, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* IMUL_INT_MUL_SCYCLE_V1_V */

