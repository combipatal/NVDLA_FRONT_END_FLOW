#!/usr/bin/env bash
set -euo pipefail

module=${1:-NV_NVDLA_partition_m}
short=${module#NV_NVDLA_partition_}
dft_run=${2:-partition_${short}_4p0ns_dftcg_const_reset_dft}
atpg_run=${ATPG_RUN_NAME:-${dft_run}_atpg}

source 2_synthesis/1_input/env.sh

export MODULE=$module
export TMAX_CELL_LIB=${TMAX_CELL_LIB:-${SAED32_EDK_ROOT}/lib/stdcell_rvt/verilog/saed32nm.v}
export SCAN_NETLIST=${SCAN_NETLIST:-4_dft/2_output/${dft_run}/net/${module}.scan.vg}
export SCAN_SPF=${SCAN_SPF:-4_dft/2_output/${dft_run}/test/${module}.scan.spf}
export REPORT_DIR=${REPORT_DIR:-4_dft/4_report/${atpg_run}}
export LOG_DIR=${LOG_DIR:-4_dft/3_log/${atpg_run}}
export OUTPUT_DIR=${OUTPUT_DIR:-4_dft/2_output/${atpg_run}}

for required_file in "$SCAN_NETLIST" "$SCAN_SPF" "$TMAX_CELL_LIB"; do
    if [[ ! -f "$required_file" ]]; then
        echo "Error: missing input file: $required_file" >&2
        exit 1
    fi
done

mkdir -p "$REPORT_DIR" "$LOG_DIR" "$OUTPUT_DIR"

tmax \
    4_dft/scripts/run_tmax_atpg.tcl \
    -shell \
    -nostartup \
    -env MODULE "$MODULE" \
    -env TMAX_CELL_LIB "$TMAX_CELL_LIB" \
    -env SCAN_NETLIST "$SCAN_NETLIST" \
    -env SCAN_SPF "$SCAN_SPF" \
    -env REPORT_DIR "$REPORT_DIR" \
    -env OUTPUT_DIR "$OUTPUT_DIR" \
    > "$LOG_DIR/${module}.tmax.log" 2>&1

if rg -q " Error:|stopped at line|Build model aborted" "$LOG_DIR/${module}.tmax.log"; then
    echo "Error: TetraMAX run reported errors. See $LOG_DIR/${module}.tmax.log" >&2
    exit 2
fi
