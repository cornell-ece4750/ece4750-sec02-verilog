//========================================================================
// Integer Multiplier Single Cycle Implementation
//========================================================================

`ifndef IMUL_INT_MUL_SCYCLE_V3_V
`define IMUL_INT_MUL_SCYCLE_V3_V

`include "vc/trace.v"

module imul_IntMulScycleV3
(
  input  logic        clk,
  input  logic        reset,

  input  logic        istream_val,
  output logic        istream_rdy,
  input  logic [63:0] istream_msg,

  output logic        ostream_val,
  input  logic        ostream_rdy,
  output logic [31:0] ostream_msg
);

  // Slice out operands from input message

  logic [31:0] istream_msg_in0;
  assign istream_msg_in0 = istream_msg[63:32];

  logic [31:0] istream_msg_in1;
  assign istream_msg_in1 = istream_msg[31:0];

  //----------------------------------------------------------------------
  // Input Registers
  //----------------------------------------------------------------------

  logic        istream_val_reg;
  logic [31:0] istream_msg_in0_reg;
  logic [31:0] istream_msg_in1_reg;

  always @( posedge clk ) begin
    if ( reset ) begin
      istream_val_reg     <= 0;
      istream_msg_in0_reg <= 32'b0;
      istream_msg_in1_reg <= 32'b0;
    end
    else if ( ostream_rdy ) begin
      istream_val_reg     <= istream_val;
      istream_msg_in0_reg <= istream_msg_in0;
      istream_msg_in1_reg <= istream_msg_in1;
    end
  end

  //----------------------------------------------------------------------
  // Multiplication Logic
  //----------------------------------------------------------------------

  assign ostream_val = istream_val_reg;
  assign ostream_msg = istream_msg_in0_reg * istream_msg_in1_reg;

  //----------------------------------------------------------------------
  // Ready Logic
  //----------------------------------------------------------------------

  assign istream_rdy = ostream_rdy;

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x|%x", istream_msg_in0, istream_msg_in1 );
    vc_trace.append_val_rdy_str( trace_str, istream_val, istream_rdy, str );

    vc_trace.append_str( trace_str, "(" );

    $sformat( str, "%x", istream_msg_in0_reg );
    vc_trace.append_val_str( trace_str, istream_val_reg, str );
    vc_trace.append_str( trace_str, " " );

    $sformat( str, "%x", istream_msg_in1_reg );
    vc_trace.append_val_str( trace_str, istream_val_reg, str );

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", ostream_msg );
    vc_trace.append_val_rdy_str( trace_str, ostream_val, ostream_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* IMUL_INT_MUL_SCYCLE_V3_V */

