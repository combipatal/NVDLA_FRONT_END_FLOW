#!/usr/bin/env bash
set -euo pipefail

module=${1:-NV_NVDLA_partition_m}
short=${module#NV_NVDLA_partition_}

source configs/env.sh

export MODULE=$module
export FILELIST="filelists/${module}.f"
export REPORT_DIR="reports/partition_${short}/dc"
export DB_DIR="build/partition_${short}/db"

mkdir -p "$REPORT_DIR" "$DB_DIR" build/work

dc_shell -no_gui -f scripts/run_dc_elab.tcl | tee "$REPORT_DIR/${module}.elab.log"
