#!/usr/bin/env bash

# Source this file from the project root.
export PROJECT_ROOT=${PROJECT_ROOT:-$PWD}
export NVDLA_ROOT=${NVDLA_ROOT:-$PROJECT_ROOT/rtl/nvdla}

# Initial local library choice. Replace these if a different PDK/corner is required.
export TARGET_LIB=${TARGET_LIB:-/DATA/home/edu135/aes128_core/6_STA/1_input/SAED32_EDK/sc/ss0p95v125c/saed32rvt_ss0p95v125c.db}
export LINK_LIB=${LINK_LIB:-"* $TARGET_LIB"}
export MIN_LIB=${MIN_LIB:-/DATA/home/edu135/aes128_core/6_STA/1_input/SAED32_EDK/sc/ff1p16v125c/saed32rvt_ff1p16v125c.db}
export MAX_LIB=${MAX_LIB:-$TARGET_LIB}
export SYNTHETIC_LIB=${SYNTHETIC_LIB:-dw_foundation.sldb}

export DC_NUM_CORES=${DC_NUM_CORES:-4}
export DC_CLK_TRANSITION=${DC_CLK_TRANSITION:-0.05}
export DC_REPORT_CONGESTION=${DC_REPORT_CONGESTION:-0}

# Topographical DC setup. Disable with DC_TOPO_MODE=0 for logic-only runs.
export DC_TOPO_MODE=${DC_TOPO_MODE:-1}
export SAED32_EDK_ROOT=${SAED32_EDK_ROOT:-/DATA/home/edu135/aes128_core/SAED32_EDK}
export MW_TECH_FILE=${MW_TECH_FILE:-$SAED32_EDK_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf}
export MW_REFERENCE_LIBS=${MW_REFERENCE_LIBS:-"$SAED32_EDK_ROOT/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m $SAED32_EDK_ROOT/lib/io_std/milkyway/saed32_io_fc $SAED32_EDK_ROOT/lib/pll/milkyway/SAED32_PLL_FR $SAED32_EDK_ROOT/lib/sram/milkyway/SRAM32NM"}
export TLU_PLUS_MAX=${TLU_PLUS_MAX:-$SAED32_EDK_ROOT/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus}
export TLU_PLUS_MIN=${TLU_PLUS_MIN:-$SAED32_EDK_ROOT/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus}
export TECH2ITF_MAP=${TECH2ITF_MAP:-$SAED32_EDK_ROOT/tech/star_rcxt/saed32nm_tf_itf_tluplus.map}
