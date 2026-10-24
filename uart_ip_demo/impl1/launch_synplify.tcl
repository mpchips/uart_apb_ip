#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/impl1/launch_synplify.tcl
#-- Written on Sat Oct 24 19:13:36 2026

project -close
set filename "C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/impl1/impl1_syn.prj"
project -new "$filename"
set create_new 1

#device options
set_option -technology LFD2NX
set_option -part LFD2NX_40
set_option -package CABGA256C
set_option -speed_grade -9

if {$create_new == 1} {
	#-- add synthesis options
	#compilation/mapping options
	set_option -symbolic_fsm_compiler true
	set_option -resource_sharing true

	#use verilog standard option
	set_option -vlog_std v2001
	set_option -disable_io_insertion false

	#map options
	set_option -frequency 200
	set_option -maxfan 1000
	set_option -auto_constrain_io 0
	set_option -retiming false; set_option -pipe true
	set_option -force_gsr false
	set_option -compiler_compatible 0
	
	
	set_option -default_enum_encoding default

	#timing analysis options
	
	

	#automatic place and route (vendor) options
	set_option -write_apr_constraint 1

	#synplifyPro options
	set_option -syn_reduce_controlset_size 0
	set_option -stop_shift_reset_merging 0
	set_option -fix_gated_and_generated_clocks 0
	set_option -update_models_cp 0
	set_option -resolve_multiple_driver 0
	
	
	set_option -rw_check_on_ram 0
	set_option -seqshift_no_replicate 0
	set_option -automatic_compile_point 0
	
	#-- set any command lines input by customer
	
	set_option -dup false
}
#-- add_file options
add_file -constraint {C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/impl1/uart_ip_demo_impl1_cpe.ldc}
add_file -verilog {C:/lscc/radiant/2026.1.1/ip/pmi/pmi_lfd2nx.v}
add_file -vhdl -lib pmi {C:/lscc/radiant/2026.1.1/ip/pmi/pmi_lfd2nx.vhd}
set_option -include_path "C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/apb_decoder.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/apb_interface.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/apb_rdata_mux.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/debouncer.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/fifo.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/rx_controller.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/rx_counter.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/rx_shifter.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/synchronizer.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/uart_apb_top.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/uart_rx.v"
add_file -verilog -vlog_std v2001 "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/uart_tx.v"
#-- top module name
set_option -top_module {uart_apb_top}
project -result_format "vm"
project -result_file {C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/impl1/uart_ip_demo_impl1.vm}
project -save "$filename"
