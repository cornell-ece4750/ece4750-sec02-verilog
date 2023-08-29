//========================================================================
// net-msgs : Network Messages
//========================================================================
// Since there is no way to create parameterized structs, we represent
// network messages as regular bit vectors with a 2-bit field for the
// source, a 2-bit field for the destination, and an 8-bit field for
// opaque bits.
//
// Message Format:
//
//   2-bits  2-bits  8-bits    data_nbits
//  +-------+-------+--------+-------------------------+
//  | src   | dest  | opaque | data                    |
//  +-------+-------+--------+-------------------------+
//
// We do define a network header struct, so that users can easily access
// the header fields like this:
//
//  net_msg_hdr_t net_msg_hdr;
//  net_msg_hdr = net_msg[`VC_NET_MSGS_HDR(msg_nbits)];
//
// Then the user can use net_msg_hdr.src or net_msg_hdr.dest.
//

`ifndef VC_NET_MSGS_V
`define VC_NET_MSGS_V

`include "vc/trace.v"

//-------------------------------------------------------------------------
// Message defines
//-------------------------------------------------------------------------

typedef struct packed {
  logic [1:0] src;
  logic [1:0] dest;
  logic [7:0] opaque;
} net_msg_hdr_t;

`define VC_NET_MSGS_HDR( msg_nbits ) msg_nbits-1:msg_nbits-12

//------------------------------------------------------------------------
// Trace message
//------------------------------------------------------------------------

module vc_NetMsgTrace
#(
  parameter p_msg_nbits = 44
)
(
  input  logic                   clk,
  input  logic                   reset,
  input  logic [p_msg_nbits-1:0] msg,
  input  logic                   val,
  input  logic                   rdy
);

  // Extract header

  net_msg_hdr_t net_msg_hdr;
  assign net_msg_hdr = msg[`VC_NET_MSGS_HDR(p_msg_nbits)];

  // Line tracing

  logic [`VC_TRACE_NBITS-1:0] str;

  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x>%x:%x", net_msg_hdr.src, net_msg_hdr.dest, net_msg_hdr.opaque );

    // Trace with val/rdy signals

    vc_trace.append_val_rdy_str( trace_str, val, rdy, str );

  end
  `VC_TRACE_END

endmodule

module vc_NetMsgMiniTrace
#(
  parameter p_msg_nbits = 44
)
(
  input  logic                   clk,
  input  logic                   reset,
  input  logic [p_msg_nbits-1:0] msg,
  input  logic                   val,
  input  logic                   rdy
);

  // Extract header

  net_msg_hdr_t net_msg_hdr;
  assign net_msg_hdr = msg[`VC_NET_MSGS_HDR(p_msg_nbits)];

  // Line tracing

  logic [`VC_TRACE_NBITS-1:0] str;

  `VC_TRACE_BEGIN
  begin

    $sformat( str, "%x>%x", net_msg_hdr.src, net_msg_hdr.dest );

    // Trace with val/rdy signals

    vc_trace.append_val_rdy_str( trace_str, val, rdy, str );

  end
  `VC_TRACE_END

endmodule

`endif /* VC_NET_MSGS_V */
