set MODULE $::env(MODULE)
set FILELIST $::env(FILELIST)
set SDC_FILE $::env(SDC_FILE)
set REPORT_DIR $::env(REPORT_DIR)
set DB_DIR $::env(DB_DIR)
set NET_DIR $::env(NET_DIR)
set FV_DIR $::env(FV_DIR)

file mkdir $REPORT_DIR
file mkdir $DB_DIR
file mkdir $NET_DIR
file mkdir $FV_DIR

source 2_synthesis/scripts/library_setup.tcl

set_host_options -max_cores $::env(DC_NUM_CORES)
set_svf $FV_DIR/${MODULE}.svf

analyze -format sverilog -vcs "-f $FILELIST" -work WORK
elaborate $MODULE
current_design $MODULE

if {![link]} {
    puts "Error: link failed for $MODULE"
    exit 1
}

read_sdc $SDC_FILE
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

redirect -file $REPORT_DIR/${MODULE}.check_design.precompile.rpt { check_design }
redirect -file $REPORT_DIR/${MODULE}.check_timing.precompile.rpt { check_timing }
redirect -file $REPORT_DIR/${MODULE}.clock.precompile.rpt { report_clocks }
redirect -file $REPORT_DIR/${MODULE}.constraint.precompile.rpt { report_constraint -all_violators -significant_digits 4 }
redirect -file $REPORT_DIR/${MODULE}.area.precompile.rpt { report_area -hierarchy }

compile_ultra -no_seq_output_inversion -no_autoungroup -scan

change_names -rules verilog -hierarchy

write -format ddc -hierarchy -output $DB_DIR/${MODULE}.ddc
write -format verilog -hierarchy -output $NET_DIR/${MODULE}.vg
write_sdc -nosplit $NET_DIR/${MODULE}.sdc
write_sdf -version 2.1 $NET_DIR/${MODULE}.sdf

redirect -file $REPORT_DIR/${MODULE}.check_design.rpt { check_design }
redirect -file $REPORT_DIR/${MODULE}.check_timing.rpt { check_timing }
redirect -file $REPORT_DIR/${MODULE}.qor.rpt { report_qor -significant_digits 4 }
redirect -file $REPORT_DIR/${MODULE}.timing.rpt {
    report_timing -max_paths 50 -nworst 5 -significant_digits 4 -input_pins -nets -transition_time -capacitance
}
redirect -file $REPORT_DIR/${MODULE}.timing.max.rpt {
    report_timing -delay_type max -max_paths 50 -nworst 5 -significant_digits 4 -input_pins -nets -transition_time -capacitance
}
redirect -file $REPORT_DIR/${MODULE}.timing.min.rpt {
    report_timing -delay_type min -max_paths 50 -nworst 5 -significant_digits 4 -input_pins -nets -transition_time -capacitance
}
redirect -file $REPORT_DIR/${MODULE}.area.rpt { report_area -hierarchy }
redirect -file $REPORT_DIR/${MODULE}.power.rpt { report_power -hierarchy }
redirect -file $REPORT_DIR/${MODULE}.constraint.rpt { report_constraint -all_violators -significant_digits 4 }
redirect -file $REPORT_DIR/${MODULE}.clock.rpt { report_clocks }
redirect -file $REPORT_DIR/${MODULE}.reference.rpt { report_reference -hierarchy }
redirect -file $REPORT_DIR/${MODULE}.resources.rpt { report_resources -hierarchy }
redirect -file $REPORT_DIR/${MODULE}.hierarchy.rpt { report_hierarchy }
redirect -file $REPORT_DIR/${MODULE}.physical.rpt {
    if {[shell_is_in_topographical_mode]} {
        report_physical_constraints
        if {[info exists ::env(DC_REPORT_CONGESTION)] && $::env(DC_REPORT_CONGESTION) eq "1"} {
            report_congestion
        } else {
            puts "Skipping report_congestion. Set DC_REPORT_CONGESTION=1 to enable it."
        }
    } else {
        puts "Not running in topographical mode."
    }
}

set_svf -off
exit
