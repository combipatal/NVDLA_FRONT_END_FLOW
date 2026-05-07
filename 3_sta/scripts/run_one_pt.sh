#!/usr/bin/env bash
set -euo pipefail

module=${1:-NV_NVDLA_partition_m}
short=${module#NV_NVDLA_partition_}
synth_run=${2:-${SYNTH_RUN_NAME:-partition_${short}_4p0ns}}
sta_run=${PT_RUN_NAME:-$synth_run}

source 2_synthesis/1_input/env.sh

export MODULE=$module
export NETLIST=${NETLIST:-2_synthesis/2_output/${synth_run}/net/${module}.vg}
export SDC_FILE=${SDC_FILE:-2_synthesis/2_output/${synth_run}/net/${module}.sdc}
export SDF_FILE=${SDF_FILE:-2_synthesis/2_output/${synth_run}/net/${module}.sdf}
export REPORT_DIR=${REPORT_DIR:-3_sta/4_report/${sta_run}}
export LOG_DIR=${LOG_DIR:-3_sta/3_log/${sta_run}}
export OUTPUT_DIR=${OUTPUT_DIR:-3_sta/2_output/${sta_run}}

for required_file in "$NETLIST" "$SDC_FILE"; do
    if [[ ! -f "$required_file" ]]; then
        echo "Error: missing input file: $required_file" >&2
        exit 1
    fi
done

if [[ "${PT_READ_SDF:-0}" == "1" && ! -f "$SDF_FILE" ]]; then
    echo "Error: PT_READ_SDF=1 but missing SDF file: $SDF_FILE" >&2
    exit 1
fi

mkdir -p "$REPORT_DIR" "$LOG_DIR" "$OUTPUT_DIR"

pt_shell \
    -file 3_sta/scripts/run_pt.tcl \
    -output_log_file "$LOG_DIR/${module}.pt.log"
