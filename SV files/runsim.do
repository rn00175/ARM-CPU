# Create Work Library
vlib work

#Compile Verilog files
#   All Verilog files that are part of the design should have
#   Their own "vlog" line

vlog "./prog_counter.sv"
vlog "./mux.sv"

#Call vsim to invoke simulator
#   Last item on the line should be the testbench module
#   to execute
vsim -voptargs="+acc" -sv_seed random -t 1ps -lib work prog_counter_tb

#Source the wave do file
do  progc_wave.do

#Set window types
view wave
view structure
view signals
view transcript

#Run simulation
run -all