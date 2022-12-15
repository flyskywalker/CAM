TB_TOP = CAM_tb

comp:
	vcs -full64 -sverilog \
	+v2k \
	-timescale=1ns/1ps -debug_all \
	-debug_acc+all+dmptf -debug_region+cell+encrypt \
	-l ${TB_TOP}comp.log \
	-kdb -lca \
	+vcs+initreg+random \
	-f ${TB_TOP}.lst -top ${TB_TOP}

sim:
	./simv -l run.log -verdi \
	+ntb_random_seed_automatic &

clean:
	rm -r *.log *.vpd *.vcd *.fsdb
