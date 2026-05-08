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

# Emit guide_hier_map guidance into the SVF for Formality R2N.
# This must be enabled before reading RTL, and set_verification_top must run
# after elaboration before commands that can modify the design.
set_app_var hdlin_enable_hier_map true
if {[info exists ::env(DC_HDLIN_VERIFICATION_PRIORITY)] && $::env(DC_HDLIN_VERIFICATION_PRIORITY) eq "1"} {
    set_app_var hdlin_verification_priority true
}

analyze -format sverilog -vcs "-f $FILELIST" -work WORK
elaborate $MODULE
current_design $MODULE
set_verification_top

if {![link]} {
    puts "Error: link failed for $MODULE"
    exit 1
}

read_sdc $SDC_FILE
if {[info exists ::env(DC_CLK_PERIOD)] && $::env(DC_CLK_PERIOD) ne ""} {
    set clk_period $::env(DC_CLK_PERIOD)
    set clk_transition 0.05
    if {[info exists ::env(DC_CLK_TRANSITION)] && $::env(DC_CLK_TRANSITION) ne ""} {
        set clk_transition $::env(DC_CLK_TRANSITION)
    }

    if {[catch {set existing_clocks [get_clocks nvdla_core_clk]} err]} {
        set existing_clocks [list]
    }
    if {![catch {sizeof_collection $existing_clocks} clock_count] && $clock_count > 0} {
        remove_clock $existing_clocks
    }

    create_clock -name nvdla_core_clk \
        -period $clk_period \
        -waveform [list 0 [expr {$clk_period / 2.0}]] \
        [get_ports nvdla_core_clk]
    set_clock_transition -max -rise $clk_transition [get_clocks nvdla_core_clk]
    set_clock_transition -max -fall $clk_transition [get_clocks nvdla_core_clk]
    set_clock_transition -min -rise $clk_transition [get_clocks nvdla_core_clk]
    set_clock_transition -min -fall $clk_transition [get_clocks nvdla_core_clk]
    puts "Info: Overrode nvdla_core_clk period to ${clk_period} ns."
}
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

proc apply_verification_priority {label objects level} {
    set count 0
    if {[catch {sizeof_collection $objects} count] || $count == 0} {
        puts "Info: No objects found for verification priority target '$label'."
        return 0
    }

    if {$level eq "high"} {
        set_verification_priority -high $objects
    } elseif {$level eq "low"} {
        set_verification_priority -low $objects
    } else {
        set_verification_priority $objects
    }
    puts "Info: Applied ${level} verification priority to $count object(s) for '$label'."
    return $count
}

set cmac_priority_cells [get_cells -quiet -hierarchical "*/u_mac_*"]
set cmac_priority_designs [get_designs -quiet "NV_NVDLA_CMAC_CORE_mac"]
set cmac_priority_references [get_references -quiet "NV_NVDLA_CMAC_CORE_mac"]
set cmac_mul_priority_designs [get_designs -quiet "NV_NVDLA_CMAC_CORE_MAC_mul"]
set cmac_mul_priority_references [get_references -quiet "NV_NVDLA_CMAC_CORE_MAC_mul"]
set dc_verification_priority_level "high"
if {[info exists ::env(DC_VERIFICATION_PRIORITY_LEVEL)] && $::env(DC_VERIFICATION_PRIORITY_LEVEL) ne ""} {
    set dc_verification_priority_level $::env(DC_VERIFICATION_PRIORITY_LEVEL)
}
if {[info exists ::env(DC_CMAC_VERIFICATION_PRIORITY)] && $::env(DC_CMAC_VERIFICATION_PRIORITY) eq "1"} {
    set cmac_priority_cell_count [apply_verification_priority "cmac_mac_cells" $cmac_priority_cells $dc_verification_priority_level]
    set cmac_priority_design_count [apply_verification_priority "cmac_mac_designs" $cmac_priority_designs $dc_verification_priority_level]
    set cmac_priority_reference_count [apply_verification_priority "cmac_mac_references" $cmac_priority_references $dc_verification_priority_level]
    set cmac_mul_priority_design_count [apply_verification_priority "cmac_mul_designs" $cmac_mul_priority_designs $dc_verification_priority_level]
    set cmac_mul_priority_reference_count [apply_verification_priority "cmac_mul_references" $cmac_mul_priority_references $dc_verification_priority_level]
} else {
    set cmac_priority_cell_count 0
    set cmac_priority_design_count 0
    set cmac_priority_reference_count 0
    set cmac_mul_priority_design_count 0
    set cmac_mul_priority_reference_count 0
}
set dc_hdlin_verification_priority ""
if {[info exists ::env(DC_HDLIN_VERIFICATION_PRIORITY)]} {
    set dc_hdlin_verification_priority $::env(DC_HDLIN_VERIFICATION_PRIORITY)
}
set dc_cmac_verification_priority ""
if {[info exists ::env(DC_CMAC_VERIFICATION_PRIORITY)]} {
    set dc_cmac_verification_priority $::env(DC_CMAC_VERIFICATION_PRIORITY)
}
redirect -file $REPORT_DIR/${MODULE}.verification_priority.precompile.rpt {
    puts "DC_HDLIN_VERIFICATION_PRIORITY=$dc_hdlin_verification_priority"
    puts "DC_CMAC_VERIFICATION_PRIORITY=$dc_cmac_verification_priority"
    puts "DC_VERIFICATION_PRIORITY_LEVEL=$dc_verification_priority_level"
    puts "CMAC priority cell count: $cmac_priority_cell_count"
    puts "CMAC priority design count: $cmac_priority_design_count"
    puts "CMAC priority reference count: $cmac_priority_reference_count"
    puts "CMAC MUL priority design count: $cmac_mul_priority_design_count"
    puts "CMAC MUL priority reference count: $cmac_mul_priority_reference_count"
    puts ""
    puts "CMAC priority cells:"
    foreach_in_collection cell $cmac_priority_cells {
        puts [get_object_name $cell]
    }
    puts ""
    puts "CMAC priority designs:"
    foreach_in_collection design $cmac_priority_designs {
        puts [get_object_name $design]
    }
    puts ""
    puts "CMAC priority references:"
    foreach_in_collection reference $cmac_priority_references {
        puts [get_object_name $reference]
    }
    puts ""
    puts "CMAC MUL priority designs:"
    foreach_in_collection design $cmac_mul_priority_designs {
        puts [get_object_name $design]
    }
    puts ""
    puts "CMAC MUL priority references:"
    foreach_in_collection reference $cmac_mul_priority_references {
        puts [get_object_name $reference]
    }
}

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
