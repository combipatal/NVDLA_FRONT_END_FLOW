#!/usr/bin/env bash

# Source this file from the project root.
export PROJECT_ROOT=${PROJECT_ROOT:-$PWD}
export NVDLA_ROOT=${NVDLA_ROOT:-$PROJECT_ROOT/rtl/nvdla}

# Initial local library choice. Replace these if a different PDK/corner is required.
export TARGET_LIB=${TARGET_LIB:-/DATA/home/edu135/aes128_core/6_STA/1_input/SAED32_EDK/sc/ss0p95v125c/saed32rvt_ss0p95v125c.db}
export LINK_LIB=${LINK_LIB:-"* $TARGET_LIB"}
export MIN_LIB=${MIN_LIB:-/DATA/home/edu135/aes128_core/6_STA/1_input/SAED32_EDK/sc/ff1p16v125c/saed32rvt_ff1p16v125c.db}
export MAX_LIB=${MAX_LIB:-$TARGET_LIB}

export DC_NUM_CORES=${DC_NUM_CORES:-4}
