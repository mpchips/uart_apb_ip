if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2026.1.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo"
if {![file exists {C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/impl1}]} {
  file mkdir {C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/impl1}
}
cd {C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/impl1}
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- uart_ip_demo_impl1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn synpro -f "uart_ip_demo_impl1.cprj" -a "LFD2NX"  -o uart_ip_demo_impl1_cpe.ldc
# synthesize top design
file delete -force -- uart_ip_demo_impl1.vm uart_ip_demo_impl1.ldc
if {[file normalize "C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/impl1/uart_ip_demo_impl1_synplify.tcl"] != [file normalize "./uart_ip_demo_impl1_synplify.tcl"]} {
  file copy -force "C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/impl1/uart_ip_demo_impl1_synplify.tcl" "./uart_ip_demo_impl1_synplify.tcl"
}
if {[ catch {::radiant::runengine::run_engine synpwrap -prj "uart_ip_demo_impl1_synplify.tcl" -log "uart_ip_demo_impl1.srf"} result options ]} {
    file delete -force -- uart_ip_demo_impl1.vm uart_ip_demo_impl1.ldc
    return -options $options $result
}
::radiant::runengine::run_postsyn [list -a LFD2NX -p LFD2NX-40 -t CABGA256 -sp 9_High-Performance_1.0V -oc Commercial -top -w -o uart_ip_demo_impl1_syn.udb uart_ip_demo_impl1.vm] [list uart_ip_demo_impl1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
