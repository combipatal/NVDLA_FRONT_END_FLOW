#!/usr/bin/env bash
set -euo pipefail

module=${1:-NV_NVDLA_partition_m}
short=${module#NV_NVDLA_partition_}

source 2_synthesis/1_input/env.sh

run_name=${DC_RUN_NAME:-partition_${short}}
if [[ -n "${DC_CLK_PERIOD:-}" && -z "${DC_RUN_NAME:-}" ]]; then
    period_tag=${DC_CLK_PERIOD//./p}
    run_name="partition_${short}_${period_tag}ns"
fi

export MODULE=$module
export FILELIST=${DC_FILELIST:-2_synthesis/1_input/filelists/${module}.f}
export SDC_FILE="2_synthesis/1_input/constraints/${module}.sdc"
export DC_RUN_NAME=$run_name
export REPORT_DIR="2_synthesis/4_report/${run_name}"
export LOG_DIR="2_synthesis/3_log/${run_name}"
export DB_DIR="2_synthesis/2_output/${run_name}/db"
export NET_DIR="2_synthesis/2_output/${run_name}/net"
export FV_DIR="2_synthesis/2_output/${run_name}/fv"
export WORK_DIR="2_synthesis/2_output/work"
export MW_DIR="2_synthesis/2_output/${run_name}/mw"
export MW_DESIGN_LIB="${MW_DIR}/${module}_mw"

mkdir -p "$REPORT_DIR" "$LOG_DIR" "$DB_DIR" "$NET_DIR" "$FV_DIR" "$WORK_DIR" "$MW_DIR"

dc_args=(-no_gui)
if [[ "${DC_TOPO_MODE:-1}" != "0" ]]; then
    dc_args+=(-topographical_mode)
fi

dc_shell "${dc_args[@]}" -f 2_synthesis/scripts/run_dc.tcl -output_log_file "$LOG_DIR/${module}.dc.log"
