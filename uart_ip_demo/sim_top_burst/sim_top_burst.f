-L work
-reflib pmi_work
-reflib ovi_lfd2nx


"C:/Users/mpiatos/Documents/Personal/design_projects/uart/tb/uart_burst_tb.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/apb_decoder.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/apb_interface.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/apb_rdata_mux.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/debouncer.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/fifo.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/rx_controller.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/rx_counter.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/rx_shifter.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/synchronizer.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/uart_apb_top.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/uart_rx.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/uart_tx.v" 
-optionset VOPTDEBUG
+noacc+pmi_work.*
+noacc+ovi_lfd2nx.*

-vopt.options
  -suppress vopt-7033
-end

-gui
-top uart_burst_tb
-vsim.options
  -suppress vsim-7033,vsim-8630,3009,3389
-end

-do "view wave"
-do "add wave /*"
-do "run -all"
