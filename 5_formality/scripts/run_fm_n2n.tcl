set MODULE $::env(MODULE)
set REF_DDC $::env(REF_DDC)
set IMPL_DDC $::env(IMPL_DDC)
set REPORT_DIR $::env(REPORT_DIR)
set OUTPUT_DIR $::env(OUTPUT_DIR)

file mkdir $REPORT_DIR
file mkdir $OUTPUT_DIR

proc safe_report {file script} {
    if {[catch {redirect -file $file $script} err]} {
        puts "Warning: failed to write $file: $err"
    }
}

proc set_constant_if_exists {container top port value} {
    set obj ${container}:/WORK/${top}/${port}
    if {![catch {set result [set_constant -type port $obj $value]} err] && $result == 1} {
        puts "Info: Set $container port $port to constant $value."
    } else {
        puts "Info: Did not set $container port $port: $err"
    }
}

set_app_var search_path [list . $::env(PROJECT_ROOT) $::env(NVDLA_ROOT)/vmod]
set_app_var verification_set_undriven_signals synthesis

if {[info exists ::env(TARGET_LIB)] && $::env(TARGET_LIB) ne ""} {
    read_db $::env(TARGET_LIB)
}

read_ddc -r $REF_DDC

set_top r:/WORK/$MODULE

read_ddc -i $IMPL_DDC
set_top i:/WORK/$MODULE

# Compare post-DFT logic in functional mode.
set_constant_if_exists i $MODULE scan_enable 0
set_constant_if_exists i $MODULE scan_in 0
set_constant_if_exists r $MODULE test_mode 0
set_constant_if_exists i $MODULE test_mode 0
set_constant_if_exists r $MODULE tmc2slcg_disable_clock_gating 0
set_constant_if_exists i $MODULE tmc2slcg_disable_clock_gating 0

safe_report $REPORT_DIR/${MODULE}.fm.setup.rpt {
    report_setup_status
    report_constants
    report_designs
    report_libraries
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
    puts "Error: Formality N2N verification failed for $MODULE."
    exit 2
}

puts "Info: Formality N2N verification passed for $MODULE."
exit
