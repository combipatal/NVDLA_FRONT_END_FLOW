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
if {[info exists ::env(FM_FAILING_POINT_LIMIT)] && $::env(FM_FAILING_POINT_LIMIT) ne ""} {
    set_app_var verification_failing_point_limit $::env(FM_FAILING_POINT_LIMIT)
}
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

if {[info exists ::env(FM_DONT_VERIFY_FILE)] && $::env(FM_DONT_VERIFY_FILE) ne ""} {
    set dont_verify_file $::env(FM_DONT_VERIFY_FILE)
    if {[file exists $dont_verify_file]} {
        set fp [open $dont_verify_file r]
        set dont_verify_points [list]
        while {[gets $fp line] >= 0} {
            set line [string trim $line]
            if {$line eq "" || [string match "#*" $line]} {
                continue
            }
            lappend dont_verify_points $line
        }
        close $fp
        if {[llength $dont_verify_points] > 0} {
            set_dont_verify_points $dont_verify_points
        }
    } else {
        puts "Error: FM_DONT_VERIFY_FILE does not exist: $dont_verify_file"
        exit 1
    }
}

safe_report $REPORT_DIR/${MODULE}.fm.setup.rpt {
    report_setup_status
    report_designs
    report_libraries
    report_svf_operation -summary
    report_dont_verify_points
}

match

safe_report $REPORT_DIR/${MODULE}.fm.match.rpt {
    report_matched_points
    report_unmatched_points
}

set verify_status [verify]

if {$verify_status != 1 && [info exists ::env(FM_ANALYZE_POINTS)] && $::env(FM_ANALYZE_POINTS) ne ""} {
    set analyze_target $::env(FM_ANALYZE_POINTS)
    set analyze_limit 50
    if {[info exists ::env(FM_ANALYZE_LIMIT)] && $::env(FM_ANALYZE_LIMIT) ne ""} {
        set analyze_limit $::env(FM_ANALYZE_LIMIT)
    }
    if {[catch {analyze_points -$analyze_target -effort low -limit $analyze_limit} err]} {
        puts "Warning: analyze_points failed for $analyze_target: $err"
    } else {
        safe_report $REPORT_DIR/${MODULE}.fm.analysis.rpt {
            report_analysis_results
        }
    }
}

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
