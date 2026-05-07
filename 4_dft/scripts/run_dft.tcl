set MODULE $::env(MODULE)
set DDC_IN $::env(DDC_IN)
set SDC_FILE $::env(SDC_FILE)
set REPORT_DIR $::env(REPORT_DIR)
set DB_DIR $::env(DB_DIR)
set NET_DIR $::env(NET_DIR)
set TEST_DIR $::env(TEST_DIR)

file mkdir $REPORT_DIR
file mkdir $DB_DIR
file mkdir $NET_DIR
file mkdir $TEST_DIR

source 2_synthesis/scripts/library_setup.tcl

if {[info exists ::env(DC_NUM_CORES)] && $::env(DC_NUM_CORES) ne ""} {
    set_host_options -max_cores $::env(DC_NUM_CORES)
}

read_ddc $DDC_IN
current_design $MODULE
link
read_sdc $SDC_FILE

if {[info exists ::env(DFT_CLK_PERIOD)] && $::env(DFT_CLK_PERIOD) ne ""} {
    set clk_period $::env(DFT_CLK_PERIOD)
    set clk_transition 0.05
    if {[info exists ::env(DC_CLK_TRANSITION)] && $::env(DC_CLK_TRANSITION) ne ""} {
        set clk_transition $::env(DC_CLK_TRANSITION)
    }

    set existing_clocks [get_clocks -quiet nvdla_core_clk]
    if {[sizeof_collection $existing_clocks] > 0} {
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
    puts "Info: Overrode nvdla_core_clk period to ${clk_period} ns for DFT."
}

set chain_count 1
if {[info exists ::env(DFT_CHAIN_COUNT)] && $::env(DFT_CHAIN_COUNT) ne ""} {
    set chain_count $::env(DFT_CHAIN_COUNT)
}

proc safe_report {file script} {
    if {[catch {redirect -file $file $script} err]} {
        puts "Warning: failed to write $file: $err"
    }
}

proc ensure_port {name direction} {
    set ports [get_ports -quiet $name]
    if {[sizeof_collection $ports] == 0} {
        create_port $name -direction $direction
    }
}

ensure_port scan_enable in
ensure_port scan_in in
ensure_port scan_out out

set_scan_configuration -test_mode all -style multiplexed_flip_flop
set_scan_configuration -test_mode all -chain_count $chain_count
set_scan_configuration -test_mode all -internal_clocks none
set_dft_configuration -connect_clock_gating enable

set_dft_signal -view existing_dft -type ScanClock -port nvdla_core_clk -timing {45 55}
set_dft_signal -view existing_dft -type Reset -port direct_reset_ -active_state 0
set_dft_signal -view existing_dft -type Reset -port dla_reset_rstn -active_state 0
set_dft_signal -view existing_dft -type TestMode -port test_mode -active_state 1
set_dft_signal -view existing_dft -type TestMode -port tmc2slcg_disable_clock_gating -active_state 1

set_dft_signal -view spec -type ScanEnable -port [get_ports scan_enable] -active_state 1
set_dft_signal -view spec -type ScanDataIn -port [get_ports scan_in]
set_dft_signal -view spec -type ScanDataOut -port [get_ports scan_out]

set nvdla_clock_gates [get_cells -hier -quiet *p_clkgate*]
if {[sizeof_collection $nvdla_clock_gates] > 0} {
    set_dft_clock_gating_pin $nvdla_clock_gates \
        -pin_name TE \
        -control_signal ScanEnable \
        -active_state 1
    set_scan_element false $nvdla_clock_gates
    puts "Info: Marked [sizeof_collection $nvdla_clock_gates] NVDLA clock-gating cells for scan_enable hookup."
} else {
    puts "Warning: No NVDLA clock-gating cells matched '*p_clkgate*'."
}

create_test_protocol

safe_report $REPORT_DIR/${MODULE}.check_design.pre_dft.rpt { check_design }
safe_report $REPORT_DIR/${MODULE}.check_timing.pre_dft.rpt { check_timing }
safe_report $REPORT_DIR/${MODULE}.dft_signal.rpt { report_dft_signal }
safe_report $REPORT_DIR/${MODULE}.dft_configuration.rpt { report_dft_configuration }
safe_report $REPORT_DIR/${MODULE}.dft_clock_gating_pin.rpt { report_dft_clock_gating_pin }
safe_report $REPORT_DIR/${MODULE}.preview_dft.rpt { preview_dft }
safe_report $REPORT_DIR/${MODULE}.dft_drc.pre_dft.rpt { dft_drc }

if {![info exists ::env(DFT_INSERT)] || $::env(DFT_INSERT) ne "0"} {
    insert_dft
    change_names -rules verilog -hierarchy

    write -format ddc -hierarchy -output $DB_DIR/${MODULE}.scan.ddc
    write -format verilog -hierarchy -output $NET_DIR/${MODULE}.scan.vg
    write_sdc -nosplit $NET_DIR/${MODULE}.scan.sdc
    write_sdf -version 2.1 $NET_DIR/${MODULE}.scan.sdf

    if {[catch {write_test_protocol -output $TEST_DIR/${MODULE}.scan.spf} err]} {
        puts "Warning: failed to write SPF: $err"
    }

    safe_report $REPORT_DIR/${MODULE}.check_design.post_dft.rpt { check_design }
    safe_report $REPORT_DIR/${MODULE}.check_timing.post_dft.rpt { check_timing }
    safe_report $REPORT_DIR/${MODULE}.dft_drc.post_dft.rpt { dft_drc }
    safe_report $REPORT_DIR/${MODULE}.scan_path.rpt { report_scan_path }
    safe_report $REPORT_DIR/${MODULE}.qor.post_dft.rpt { report_qor -significant_digits 4 }
    safe_report $REPORT_DIR/${MODULE}.timing.post_dft.rpt {
        report_timing -max_paths 50 -nworst 5 -significant_digits 4 -input_pins -nets -transition_time -capacitance
    }
    safe_report $REPORT_DIR/${MODULE}.constraint.post_dft.rpt {
        report_constraint -all_violators -significant_digits 4
    }
    safe_report $REPORT_DIR/${MODULE}.area.post_dft.rpt { report_area -hierarchy }
}

exit
