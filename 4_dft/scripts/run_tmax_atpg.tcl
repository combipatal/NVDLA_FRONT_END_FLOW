set module $env(MODULE)
set tmax_cell_lib $env(TMAX_CELL_LIB)
set scan_netlist $env(SCAN_NETLIST)
set scan_spf $env(SCAN_SPF)
set report_dir $env(REPORT_DIR)
set output_dir $env(OUTPUT_DIR)

file mkdir $report_dir
file mkdir $output_dir

read_netlist $tmax_cell_lib -library
read_netlist $scan_netlist
run_build_model $module

run_drc $scan_spf

set_faults -model stuck
add_faults -all
run_atpg

report_summaries > $report_dir/${module}.tmax.summary.rpt
report_faults -summary > $report_dir/${module}.tmax.fault_summary.rpt
report_patterns -summary > $report_dir/${module}.tmax.pattern_summary.rpt

write_patterns $output_dir/${module}.stuck.stil -format stil -replace
write_faults $output_dir/${module}.stuck.faults -all -replace

quit
