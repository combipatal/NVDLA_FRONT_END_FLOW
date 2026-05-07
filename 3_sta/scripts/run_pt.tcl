set MODULE $::env(MODULE)
set NETLIST $::env(NETLIST)
set SDC_FILE $::env(SDC_FILE)
set REPORT_DIR $::env(REPORT_DIR)
set OUTPUT_DIR $::env(OUTPUT_DIR)

file mkdir $REPORT_DIR
file mkdir $OUTPUT_DIR

if {![info exists ::env(MAX_LIB)] || $::env(MAX_LIB) eq ""} {
    puts "Error: MAX_LIB is not set. Source 2_synthesis/1_input/env.sh before running."
    exit 1
}

set_app_var search_path [list . $::env(PROJECT_ROOT) $::env(NVDLA_ROOT)/vmod]
set_app_var link_path [list * $::env(MAX_LIB)]

read_verilog $NETLIST
link_design $MODULE
current_design $MODULE

if {[info exists ::env(MIN_LIB)] && $::env(MIN_LIB) ne "" && $::env(MIN_LIB) ne $::env(MAX_LIB)} {
    set_min_library $::env(MAX_LIB) -min_version $::env(MIN_LIB)
}

read_sdc $SDC_FILE

if {[info exists ::env(PT_READ_SDF)] && $::env(PT_READ_SDF) eq "1"} {
    if {![info exists ::env(SDF_FILE)] || $::env(SDF_FILE) eq ""} {
        puts "Error: PT_READ_SDF=1 but SDF_FILE is not set."
        exit 1
    }
    read_sdf $::env(SDF_FILE)
}

update_timing -full

redirect -file $REPORT_DIR/${MODULE}.pt.check_timing.rpt {
    check_timing -verbose
}
redirect -file $REPORT_DIR/${MODULE}.pt.analysis_coverage.rpt {
    report_analysis_coverage
}
redirect -file $REPORT_DIR/${MODULE}.pt.clock.rpt {
    report_clock
}
redirect -file $REPORT_DIR/${MODULE}.pt.constraint.rpt {
    report_constraint -all_violators -significant_digits 4
}
redirect -file $REPORT_DIR/${MODULE}.pt.qor.rpt {
    report_qor -significant_digits 4
}
redirect -file $REPORT_DIR/${MODULE}.pt.global_timing.rpt {
    report_global_timing -significant_digits 4
}
redirect -file $REPORT_DIR/${MODULE}.pt.timing.max.rpt {
    report_timing -delay_type max -max_paths 50 -nworst 5 -significant_digits 4 -input_pins -nets -transition_time -capacitance
}
redirect -file $REPORT_DIR/${MODULE}.pt.timing.min.rpt {
    report_timing -delay_type min -max_paths 50 -nworst 5 -significant_digits 4 -input_pins -nets -transition_time -capacitance
}
redirect -file $REPORT_DIR/${MODULE}.pt.timing.summary.rpt {
    report_timing -delay_type max -max_paths 10 -significant_digits 4
    report_timing -delay_type min -max_paths 10 -significant_digits 4
}

write_session -output $OUTPUT_DIR/${MODULE}.pt_session
exit
