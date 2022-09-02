#=========================================================================
# imul-v3-adhoc-test <input-values>
#=========================================================================

from sys import argv

from pymtl3  import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib.stream import StreamSourceFL, StreamSinkFL

from IntMulScycleV3 import IntMulScycleV3

#-------------------------------------------------------------------------
# TestHarness
#-------------------------------------------------------------------------

class TestHarness( Component ):

  def construct( s, imsgs, omsgs ):

    # Instantiate models

    s.src  = StreamSourceFL( Bits64, msgs=imsgs, initial_delay=0, interval_delay=0 )
    s.sink = StreamSinkFL  ( Bits32, msgs=omsgs, initial_delay=0, interval_delay=0 )
    s.imul = IntMulScycleV3()

    # Connect

    s.src.ostream  //= s.imul.istream
    s.imul.ostream //= s.sink.istream

  def done( s ):
    return s.src.done() and s.sink.done()

  def line_trace( s ):
    return s.src.line_trace() + " > " + s.imul.line_trace() + " > " + s.sink.line_trace()

#-------------------------------------------------------------------------
# Simulate
#-------------------------------------------------------------------------

# Get list of input values from command line

in0_values = [ int(x,0) for x in argv[1::2] ]
in1_values = [ int(x,0) for x in argv[2::2] ]

# Put input values as input messages into the stream source

imsgs = []
omsgs = []
for in0_value,in1_value in zip(in0_values,in1_values):
  in0_bits = Bits32(in0_value)
  in1_bits = Bits32(in1_value)
  imsgs.extend([ concat( in0_bits, in1_bits ) ])
  omsgs.extend([ Bits32( in0_bits * in1_bits, trunc_int=True ) ])

# Create and elaborate the model

th = TestHarness( imsgs, omsgs )
th.elaborate()

# Apply the Verilog import passes and the default pass group

th.apply( VerilogPlaceholderPass() )
th = VerilogTranslationImportPass()( th )
th.apply( DefaultPassGroup(linetrace=True,textwave=True,vcdwave="imul-v3-adhoc-test") )

# Reset simulator

th.sim_reset()

# Apply input values and display output values

while not th.done():
  th.sim_tick()

# Tick simulator three more cycles and print text wave

th.sim_tick()
th.sim_tick()
th.sim_tick()
th.print_textwave()

