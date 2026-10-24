# regression for the APB UART: compiles src/ and tb/, runs every testbench,
# and prints one overall PASS/FAIL
#
# usage, from a working folder next to src/ and tb/ (for example sim/):
#   vsim -c -do "do ../tb/run_all.do"
# or from any folder, passing the project folder:
#   vsim -c -do "do <project>/tb/run_all.do <project>"
#
# a test passes when its fail_cnt is 0 and its pass_cnt is above 0 after
# $finish. The exit code is 0 on PASS and 1 on FAIL

if {$argc >= 1} {
    set proj_dir [file normalize $1]
} else {
    set proj_dir [file normalize ..]
}
set tb_dir  [file join $proj_dir tb]
set src_dir [file join $proj_dir src]

# each entry: {name  top-level module  extra vsim options}
set tests {
    {fifo_tb_depth2    fifo_tb            -GFIFO_DEPTH=2}
    {fifo_tb_depth16   fifo_tb            -GFIFO_DEPTH=16}
    {uart_burst_tb     uart_burst_tb      {}}
    {uart_frame_err_tb uart_frame_err_tb  {}}
    {uart_reg_tb       uart_reg_tb        {}}
    {uart_ovr_tb       uart_ovr_tb        {}}
}

onerror {resume}

if {[file exists work]} {
    vdel -lib work -all
}
vlib work

if {[catch {vlog -lint {*}[glob $src_dir/*.v] {*}[glob $tb_dir/*.v]} msg]} {
    echo "REGRESSION: FAIL (compile error)"
    quit -code 1
}

set results {}
set all_pass 1

foreach t $tests {
    lassign $t name top opts

    # +acc keeps pass_cnt and fail_cnt visible to examine
    if {[catch {vsim -onfinish stop -voptargs=+acc {*}$opts work.$top} msg]} {
        lappend results [list $name "FAIL (did not load)"]
        set all_pass 0
        continue
    }
    run -all

    if {[catch {
        set fails  [examine -radix decimal /$top/fail_cnt]
        set passes [examine -radix decimal /$top/pass_cnt]
    } msg]} {
        lappend results [list $name "FAIL (could not read pass/fail counters)"]
        set all_pass 0
        quit -sim
        continue
    }

    if {($fails == 0) && ($passes > 0)} {
        lappend results [list $name "PASS ($passes checks)"]
    } else {
        lappend results [list $name "FAIL ($fails of [expr {$fails + $passes}] checks failed)"]
        set all_pass 0
    }
    quit -sim
}

echo ""
echo "================ regression summary ================"
foreach r $results {
    echo [format "  %-20s %s" [lindex $r 0] [lindex $r 1]]
}
echo "===================================================="
if {[llength $results] != [llength $tests]} {
    set all_pass 0
}
if {$all_pass} {
    echo "REGRESSION: PASS"
    quit -code 0
} else {
    echo "REGRESSION: FAIL"
    quit -code 1
}
