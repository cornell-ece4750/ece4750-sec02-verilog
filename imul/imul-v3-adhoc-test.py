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
# mk_imsg/mk_omsg
#-------------------------------------------------------------------------
# Make input/output msgs, truncate ints to ensure they fit in 32 bits.

def mk_imsg( a, b ):
  return concat( Bits32( a, trunc_int=True ), Bits32( b, trunc_int=True ) )

def mk_omsg( a ):
  return Bits32( a, trunc_int=True )

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
  imsgs.extend([ mk_imsg( in0_value, in1_value ) ])
  omsgs.extend([ mk_omsg( in0_value * in1_value ) ])

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

