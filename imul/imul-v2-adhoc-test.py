#=========================================================================
# imul-v2-adhoc-test <input-values>
#=========================================================================

from sys import argv

from pymtl3  import *
from pymtl3.passes.backends.verilog import *

from IntMulScycleV2 import IntMulScycleV2

# Get list of input values from command line

in0_values = [ int(x,0) for x in argv[1::2] ]
in1_values = [ int(x,0) for x in argv[2::2] ]

# Create and elaborate the model

model = IntMulScycleV2()
model.elaborate()

# Apply the Verilog import passes and the default pass group

model.apply( VerilogPlaceholderPass() )
model = VerilogTranslationImportPass()( model )
model.apply( DefaultPassGroup(linetrace=True,textwave=True,vcdwave="imul-v2-adhoc-test") )

# Reset simulator

model.sim_reset()

# Apply input values and display output values

for in0_value,in1_value in zip(in0_values,in1_values):

  # Write input value to input port

  model.in_val @= 1
  model.in0    @= in0_value
  model.in1    @= in1_value
  model.sim_eval_combinational()

  # Tick simulator one cycle

  model.sim_tick()

# No more value inputs

model.in_val @= 0

# Tick simulator three more cycles and print text wave

model.sim_tick()
model.sim_tick()
model.sim_tick()
model.print_textwave()

