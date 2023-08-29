//========================================================================
// Latency-Insensitive Adder Implementation
//========================================================================

`ifndef SEC02_ADDER_V
`define SEC02_ADDER_V

`include "vc/trace.v"

module sec02_Adder
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

  // Split apart our operands
  logic [31:0] a;
  logic [31:0] b;

  assign a = istream_msg[31: 0];
  assign b = istream_msg[63:32];

  //----------------------------------------------------------------------
  // Control Logic
  //----------------------------------------------------------------------

  logic istream_send;
  logic ostream_send;

  assign istream_send = ( istream_val & istream_rdy );
  assign ostream_send = ( ostream_val & ostream_rdy );

  logic val_reg;

  always_ff @( posedge clk ) begin
    if     ( reset        ) val_reg <= 0;
    else if( istream_send ) val_reg <= 1; // New transaction
    else if( ostream_send ) val_reg <= 0; // Remove old transaction
  end

  assign ostream_val = val_reg;

  // Ready whenever we aren't valid, or are passing on the old message
  assign istream_rdy = ( ostream_send | !val_reg );

  //----------------------------------------------------------------------
  // Datapath Logic
  //----------------------------------------------------------------------

  logic [31:0] a_reg;
  logic [31:0] b_reg;

  always_ff @( posedge clk ) begin
    if( reset ) begin
      a_reg <= 32'b0;
      b_reg <= 32'b0;
    end

    else if( istream_send ) begin
      a_reg <= a;
      b_reg <= b;
    end
  end

  // Calculate the sum
  assign ostream_msg = a_reg + b_reg;

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  logic [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x", istream_msg );
    vc_trace.append_val_rdy_str( trace_str, istream_val, istream_rdy, str );

    vc_trace.append_str( trace_str, " ( " );

    if( val_reg ) begin
      $sformat( str, "%x", a_reg );
      vc_trace.append_str( trace_str, str );

      vc_trace.append_str( trace_str, " + " );

      $sformat( str, "%x", b_reg );
      vc_trace.append_str( trace_str, str );

      vc_trace.append_str( trace_str, " = " );

      $sformat( str, "%x", ostream_msg );
      vc_trace.append_str( trace_str, str );

    end

    else begin
      vc_trace.append_str( trace_str, "                              ") ;
    end

    vc_trace.append_str( trace_str, " ) " );

    $sformat( str, "%x", ostream_msg );
    vc_trace.append_val_rdy_str( trace_str, ostream_val, ostream_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */
  
endmodule

`endif /* SEC02_ADDER_V */
