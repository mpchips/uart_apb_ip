lappend auto_path "C:/lscc/radiant/2026.1.1/scripts/tcl/simulation"
package require simulation_generation
set ::bali::simulation::Para(DEVICEPM) {jd5s00}
set ::bali::simulation::Para(DEVICEFAMILYNAME) {LFD2NX}
set ::bali::simulation::Para(PROJECT) {sim_reg_access}
set ::bali::simulation::Para(MDOFILE) {}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/sim_reg_access}
set ::bali::simulation::Para(FILELIST) {"C:/Users/mpiatos/Documents/Personal/design_projects/uart/uart_ip_demo/impl1/uart_ip_demo_impl1_vo.vo" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/tb/uart_reg_tb.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/apb_decoder.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/apb_interface.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/apb_rdata_mux.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/debouncer.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/fifo.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/rx_controller.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/rx_counter.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/rx_shifter.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/sticky_flag.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/synchronizer.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/uart_apb_top.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/uart_rx.v" "C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/uart_tx.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"" "work" "" "" "" "" "" "" "" "" "" "" "" "" "" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(LANGSTDLIST) {"" "Verilog 2001" "" "" "" "" "" "" "" "" "" "" "" "" "" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_lfd2nx}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {uart_reg_tb}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {/dut}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(INSTALLATIONPATH) {C:/lscc/radiant/2026.1.1}
set ::bali::simulation::Para(MEMPATH) {}
set ::bali::simulation::Para(UDOLIST) {}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(SIMULATIONTIME)  {0}
set ::bali::simulation::Para(SIMULATIONTIMEUNIT)  {ns}
set ::bali::simulation::Para(SIMULATION_RESOLUTION)  {default}
set ::bali::simulation::Para(NOGUI) {0}
set ::bali::simulation::Para(ISRTL)  {0}
set ::bali::simulation::Para(ISQRUNCLEAN)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
set ::bali::simulation::Para(AUTOORDER)  {1}
set ::bali::simulation::Para(PERMISSIVE)  {0}
set ::bali::simulation::Para(OPTIMIZATION_DEBUG)  {1}
::bali::simulation::QuestaSim_Q_Run
