comp:
	vcs -full64 -sverilog \
	+v2k \
	-timescale=1ns/1ns \
	-debug_all -debug_acc+all \
	-l comp.log \
	-f CAM_tb.lst -top CAM_tb
sim:
	./simv -l run.log -gui &
clean:
	rm -r *.log *.vpd *.vcd *.fsdb
