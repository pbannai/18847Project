layer_tb:
	vcs -sverilog neuron.sv ffi.sv lateral_inhibition.sv spike_generation.sv layer.sv layer_tb.sv internal_defines.vh

neuron_tb:
	vcs -sverilog neuron.sv neuron_tb.sv define.vh
	./simv
