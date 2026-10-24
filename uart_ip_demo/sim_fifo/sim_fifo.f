-L work
-reflib pmi_work
-reflib ovi_lfd2nx


"C:/Users/mpiatos/Documents/Personal/design_projects/uart/tb/fifo_tb.v" 
"C:/Users/mpiatos/Documents/Personal/design_projects/uart/src/fifo.v" 
-optionset VOPTDEBUG
+noacc+pmi_work.*
+noacc+ovi_lfd2nx.*

-vopt.options
  -suppress vopt-7033
-end

-gui
-top fifo_tb
-vsim.options
  -suppress vsim-7033,vsim-8630,3009,3389
-end

-do "view wave"
-do "add wave /*"
-do "run -all"
