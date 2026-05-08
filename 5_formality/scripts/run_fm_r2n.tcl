set MODULE $::env(MODULE)
set REF_FILELIST $::env(REF_FILELIST)
set IMPL_DDC $::env(IMPL_DDC)
set SVF_FILE $::env(SVF_FILE)
set DW_VERILOG_FILES $::env(DW_VERILOG_FILES)
set REPORT_DIR $::env(REPORT_DIR)
set OUTPUT_DIR $::env(OUTPUT_DIR)

file mkdir $REPORT_DIR
file mkdir $OUTPUT_DIR

proc safe_report {file script} {
    if {[catch {redirect -file $file $script} err]} {
        puts "Warning: failed to write $file: $err"
    }
}

set_app_var search_path [list . $::env(PROJECT_ROOT) $::env(NVDLA_ROOT)/vmod]
set_app_var hdlin_ignore_parallel_case true
set_app_var verification_set_undriven_signals synthesis
if {[info exists ::env(FM_DWROOT)] && $::env(FM_DWROOT) ne ""} {
    set_app_var hdlin_dwroot $::env(FM_DWROOT)
    set_app_var hdlin_use_svf_dwroot true
}

if {[info exists ::env(TARGET_LIB)] && $::env(TARGET_LIB) ne ""} {
    read_db $::env(TARGET_LIB)
}

set_svf $SVF_FILE

foreach dw_file [split $DW_VERILOG_FILES] {
    if {$dw_file ne ""} {
        read_verilog -r $dw_file
    }
}
read_verilog -r -vcs "-f $REF_FILELIST"

set_top r:/WORK/$MODULE

read_ddc -i $IMPL_DDC
set_top i:/WORK/$MODULE

safe_report $REPORT_DIR/${MODULE}.fm.setup.rpt {
    report_setup_status
    report_designs
    report_libraries
    report_svf_operation -summary
}

match

safe_report $REPORT_DIR/${MODULE}.fm.match.rpt {
    report_matched_points
    report_unmatched_points
}

set verify_status [verify]

safe_report $REPORT_DIR/${MODULE}.fm.verify.rpt {
    report_passing_points
    report_failing_points
    report_aborted_points
    report_unverified_points
}

if {$verify_status != 1} {
    puts "Error: Formality R2N verification failed for $MODULE."
    exit 2
}

puts "Info: Formality R2N verification passed for $MODULE."
exit
