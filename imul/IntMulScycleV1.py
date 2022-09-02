#=========================================================================
# IntMulScycleV1
#=========================================================================

from pymtl3 import *
from pymtl3.passes.backends.verilog import *

class IntMulScycleV1( VerilogPlaceholder, Component ):
  def construct( s ):
    s.in0 = InPort ( 32 )
    s.in1 = InPort ( 32 )
    s.out = OutPort( 32 )

