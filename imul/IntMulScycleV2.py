#=========================================================================
# IntMulScycleV2
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class IntMulScycleV2( VerilogPlaceholder, Component ):
  def construct( s ):
    s.in_val  = InPort ()
    s.in0     = InPort ( 32 )
    s.in1     = InPort ( 32 )

    s.out_val = OutPort()
    s.out     = OutPort( 32 )

