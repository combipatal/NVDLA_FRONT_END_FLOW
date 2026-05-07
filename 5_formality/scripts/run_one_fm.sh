#!/usr/bin/env bash
set -euo pipefail

mode=${1:-r2n}
module=${2:-NV_NVDLA_partition_m}
short=${module#NV_NVDLA_partition_}
default_run="partition_${short}_4p0ns_dftcg_${mode}"
fm_run=${FM_RUN_NAME:-$default_run}

source 2_synthesis/1_input/env.sh

export MODULE=$module
export FM_MODE=$mode
export REPORT_DIR=${REPORT_DIR:-5_formality/4_report/${fm_run}}
export LOG_DIR=${LOG_DIR:-5_formality/3_log/${fm_run}}
export OUTPUT_DIR=${OUTPUT_DIR:-5_formality/2_output/${fm_run}}

case "$mode" in
    r2n)
        export REF_FILELIST=${REF_FILELIST:-2_synthesis/1_input/filelists/${module}.dft.f}
        export IMPL_DDC=${IMPL_DDC:-2_synthesis/2_output/partition_${short}_4p0ns_dftcg/db/${module}.ddc}
        export SVF_FILE=${SVF_FILE:-2_synthesis/2_output/partition_${short}_4p0ns_dftcg/fv/${module}.svf}
        export DW_VERILOG_FILES=${DW_VERILOG_FILES:-"/tools/synopsys/syn/W-2024.09-SP5-5/dw/sim_ver/DW_minmax.v /tools/synopsys/syn/W-2024.09-SP5-5/dw/sim_ver/DW02_tree.v"}
        script=5_formality/scripts/run_fm_r2n.tcl
        for required_file in "$REF_FILELIST" "$IMPL_DDC" "$SVF_FILE"; do
            if [[ ! -f "$required_file" ]]; then
                echo "Error: missing input file: $required_file" >&2
                exit 1
            fi
        done
        for required_file in $DW_VERILOG_FILES; do
            if [[ ! -f "$required_file" ]]; then
                echo "Error: missing DesignWare file: $required_file" >&2
                exit 1
            fi
        done
        ;;
    n2n)
        export REF_DDC=${REF_DDC:-2_synthesis/2_output/partition_${short}_4p0ns_dftcg/db/${module}.ddc}
        export IMPL_DDC=${IMPL_DDC:-4_dft/2_output/partition_${short}_4p0ns_dftcg_const_reset_dft/db/${module}.scan.ddc}
        script=5_formality/scripts/run_fm_n2n.tcl
        for required_file in "$REF_DDC" "$IMPL_DDC"; do
            if [[ ! -f "$required_file" ]]; then
                echo "Error: missing input file: $required_file" >&2
                exit 1
            fi
        done
        ;;
    *)
        echo "Error: unsupported Formality mode: $mode" >&2
        exit 1
        ;;
esac

mkdir -p "$REPORT_DIR" "$LOG_DIR" "$OUTPUT_DIR"

fm_shell \
    -no_init \
    -work_path "$OUTPUT_DIR/FM_WORK" \
    -overwrite \
    -file "$script" \
    > "$LOG_DIR/${module}.${mode}.fm.log" 2>&1
