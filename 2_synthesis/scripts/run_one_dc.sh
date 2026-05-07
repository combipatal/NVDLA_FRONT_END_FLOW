#!/usr/bin/env bash
set -euo pipefail

module=${1:-NV_NVDLA_partition_m}
short=${module#NV_NVDLA_partition_}

source 2_synthesis/1_input/env.sh

export MODULE=$module
export FILELIST="2_synthesis/1_input/filelists/${module}.f"
export SDC_FILE="2_synthesis/1_input/constraints/${module}.sdc"
export REPORT_DIR="2_synthesis/4_report/partition_${short}"
export LOG_DIR="2_synthesis/3_log/partition_${short}"
export DB_DIR="2_synthesis/2_output/partition_${short}/db"
export NET_DIR="2_synthesis/2_output/partition_${short}/net"
export FV_DIR="2_synthesis/2_output/partition_${short}/fv"
export WORK_DIR="2_synthesis/2_output/work"
export MW_DIR="2_synthesis/2_output/partition_${short}/mw"
export MW_DESIGN_LIB="${MW_DIR}/${module}_mw"

mkdir -p "$REPORT_DIR" "$LOG_DIR" "$DB_DIR" "$NET_DIR" "$FV_DIR" "$WORK_DIR" "$MW_DIR"

dc_args=(-no_gui)
if [[ "${DC_TOPO_MODE:-1}" != "0" ]]; then
    dc_args+=(-topographical_mode)
fi

dc_shell "${dc_args[@]}" -f 2_synthesis/scripts/run_dc.tcl -output_log_file "$LOG_DIR/${module}.dc.log"
