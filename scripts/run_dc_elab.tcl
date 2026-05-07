set MODULE $::env(MODULE)
set FILELIST $::env(FILELIST)
set REPORT_DIR $::env(REPORT_DIR)
set DB_DIR $::env(DB_DIR)

file mkdir $REPORT_DIR
file mkdir $DB_DIR

source configs/library_setup.tcl

set_host_options -max_cores $::env(DC_NUM_CORES)

analyze -format sverilog -vcs "-f $FILELIST" -work WORK
elaborate $MODULE
current_design $MODULE

if {![link]} {
    puts "Error: link failed for $MODULE"
    exit 1
}

redirect -file $REPORT_DIR/${MODULE}.check_design.elab.rpt { check_design }
write -format ddc -hierarchy -output $DB_DIR/${MODULE}.elab.ddc

exit
