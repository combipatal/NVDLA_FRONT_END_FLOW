#!/usr/bin/env bash
set -euo pipefail

module=${1:-NV_NVDLA_partition_m}
shift || true

periods=("$@")
if [[ ${#periods[@]} -eq 0 ]]; then
    periods=(4.0 3.5 3.2)
fi

short=${module#NV_NVDLA_partition_}

for period in "${periods[@]}"; do
    period_tag=${period//./p}
    export DC_CLK_PERIOD=$period
    export DC_RUN_NAME="partition_${short}_${period_tag}ns"

    echo "==> Running $module with DC_CLK_PERIOD=${period}ns into ${DC_RUN_NAME}"
    bash 2_synthesis/scripts/run_one_dc.sh "$module"
done
