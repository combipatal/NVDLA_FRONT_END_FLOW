#!/usr/bin/env bash
set -euo pipefail

module=${1:-NV_NVDLA_partition_m}
short=${module#NV_NVDLA_partition_}

source 2_synthesis/1_input/env.sh

export MODULE=$module
export FILELIST="2_synthesis/1_input/filelists/${module}.f"
export REPORT_DIR="2_synthesis/4_report/partition_${short}"
export LOG_DIR="2_synthesis/3_log/partition_${short}"
export DB_DIR="2_synthesis/2_output/partition_${short}/db"
export WORK_DIR="2_synthesis/2_output/work"

mkdir -p "$REPORT_DIR" "$LOG_DIR" "$DB_DIR" "$WORK_DIR"

dc_shell -no_gui -f 2_synthesis/scripts/run_dc_elab.tcl | tee "$LOG_DIR/${module}.elab.log"
