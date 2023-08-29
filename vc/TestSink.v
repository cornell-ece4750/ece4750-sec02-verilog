//========================================================================
// Verilog Components: Test Sink
//========================================================================
// p_sim_mode should be set to one in simulators. This will cause the
// sink to abort after the first failure with an appropriate error
// message.

`ifndef VC_TEST_SINK_V
`define VC_TEST_SINK_V

`include "vc/regs.v"
`include "vc/trace.v"

module vc_TestSink
#(
  parameter p_msg_nbits = 1,
  parameter p_num_msgs  = 1024,
  parameter p_sim_mode  = 0
)(
  input  logic                   clk,
  input  logic                   reset,

  // Sink message interface

  input  logic                   val,
  output logic                   rdy,
  input  logic [p_msg_nbits-1:0] msg,

  // Goes high once all sink data has been received

  output logic                   done
);

  //----------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------

  // Size of a physical address for the memory in bits

  localparam c_index_nbits = $clog2(p_num_msgs);

  //----------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------

  // Memory which stores messages to verify against those received

  logic [p_msg_nbits-1:0] m[p_num_msgs-1:0];

  // Index register pointing to next message to verify

  logic                     index_en;
  logic [c_index_nbits-1:0] index_next;
  logic [c_index_nbits-1:0] index;

  vc_EnResetReg#(c_index_nbits,{c_index_nbits{1'b0}}) index_reg
  (
    .clk   (clk),
    .reset (reset),
    .en    (index_en),
    .d     (index_next),
    .q     (index)
  );

  // Register reset

  logic reset_reg;
  always_ff @( posedge clk )
    reset_reg <= reset;

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  logic done_next;
  assign done_next = !reset_reg && ( index == ( p_num_msgs - 1 ) );

  always_ff @( posedge clk ) begin
    if( val && rdy ) done <= done_next;
  end

  // Sink message interface is ready as long as we are not done

  assign rdy = !reset_reg && !done;

  // We bump the index pointer every time we successfully receive a
  // message, otherwise the index stays the same.

  assign index_en   = val && rdy;
  assign index_next = index + 1'b1;

  // The go signal is high when a message is transferred

  logic go;
  assign go = val && rdy;

  //----------------------------------------------------------------------
  // Verification logic
  //----------------------------------------------------------------------

  logic        failed;
  logic  [3:0] verbose;

  logic  [p_msg_nbits-1:0] m_curr;
  assign m_curr = m[index];

  always_ff @( posedge clk ) begin
    if ( reset ) begin
      failed <= 0;
    end
    else if ( !reset && go ) begin

      casez ( msg )
        m_curr :begin
          pass();
          $display( "     [ passed ] expected = %x, actual = %x",
                    m[index], msg );
        end
        default : begin
          fail();
          failed <= 1;
          $display( "     [ FAILED ] expected = %x, actual = %x",
                    m[index], msg );
                    
          if ( p_sim_mode ) begin
            $display( "" );
            $display( " ERROR: Test sink found a failure!" );
            $display( "  - module   : %m" );
            $display( "  - expected : %x", m[index] );
            $display( "  - actual   : %x", msg );
            $display( "" );
            $display( " Verify that all unit tests pass; if they do, then debug" );
            $display( " the failure and add a new unit test which would have" );
            $display( " caught the bug in the first place." );
            $display( "" );
            $finish;
          end
        end
      endcase

    end
  end

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  always_ff @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( val );
      `VC_ASSERT_NOT_X( rdy );
    end
  end

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  // logic [`VC_TRACE_NBITS_TO_NCHARS(p_msg_nbits)*8-1:0] msg_str;

  // `VC_TRACE_BEGIN
  // begin
  //   $sformat( msg_str, "%x", msg );
  //   vc_trace.append_val_rdy_str( trace_str, val, rdy, msg_str );
  // end
  // `VC_TRACE_END

endmodule

`endif /* VC_TEST_SINK_V */
