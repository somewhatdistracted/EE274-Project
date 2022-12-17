debug:
	dve -full64 -vpd dump.vcd &

run: compile
	./simv

concat: clean
	cat verilog/symbol_buffer.sv verilog/huff_encoder_atom.sv verilog/huff_encoder.sv verilog/huff_decoder.sv rans_encoder.sv > verilog/outputs/design.sv

compile: concat
	vcs -full64 -sverilog -timescale=1ns/1ps -debug_access+pp dv/$(target).sv verilog/outputs/design.sv

clean:
	rm -rf simv
	rm -rf simv.daidir/ 
	rm -rf *.vcd
	rm -rf csrc
	rm -rf ucli.key
	rm -rf vc_hdrs.h
	rm -rf DVEfiles
	rm -rf verilog/outputs/design.v
