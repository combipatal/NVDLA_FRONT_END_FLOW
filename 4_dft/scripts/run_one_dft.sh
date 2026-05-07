#!/usr/bin/env bash
set -euo pipefail

module=${1:-NV_NVDLA_partition_m}
short=${module#NV_NVDLA_partition_}
synth_run=${2:-${SYNTH_RUN_NAME:-partition_${short}_4p0ns}}
dft_run=${DFT_RUN_NAME:-${synth_run}_dft}

source 2_synthesis/1_input/env.sh

export MODULE=$module
export DDC_IN=${DDC_IN:-2_synthesis/2_output/${synth_run}/db/${module}.ddc}
export SDC_FILE=${SDC_FILE:-2_synthesis/1_input/constraints/${module}.sdc}
export DFT_CLK_PERIOD=${DFT_CLK_PERIOD:-4.0}
export DFT_CHAIN_COUNT=${DFT_CHAIN_COUNT:-32}
export DFT_INSERT=${DFT_INSERT:-1}
export REPORT_DIR=${REPORT_DIR:-4_dft/4_report/${dft_run}}
export LOG_DIR=${LOG_DIR:-4_dft/3_log/${dft_run}}
export DB_DIR=${DB_DIR:-4_dft/2_output/${dft_run}/db}
export NET_DIR=${NET_DIR:-4_dft/2_output/${dft_run}/net}
export TEST_DIR=${TEST_DIR:-4_dft/2_output/${dft_run}/test}
export WORK_DIR=${WORK_DIR:-4_dft/2_output/work}

for required_file in "$DDC_IN" "$SDC_FILE"; do
    if [[ ! -f "$required_file" ]]; then
        echo "Error: missing input file: $required_file" >&2
        exit 1
    fi
done

mkdir -p "$REPORT_DIR" "$LOG_DIR" "$DB_DIR" "$NET_DIR" "$TEST_DIR" "$WORK_DIR"

dc_shell \
    -no_gui \
    -f 4_dft/scripts/run_dft.tcl \
    -output_log_file "$LOG_DIR/${module}.dft.log"
