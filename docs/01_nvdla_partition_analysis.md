# NVDLA Partition Analysis

## Source Snapshot

- Source: `rtl/nvdla`
- Remote: `https://github.com/nvdla/hw.git`
- Checked revision during setup: `8e06b1b`

## Reference Synthesis Flow

NVIDIA's reference flow is under `rtl/nvdla/syn`.

- Launcher: `rtl/nvdla/syn/scripts/syn_launch.sh`
- Main DC script: `rtl/nvdla/syn/scripts/dc_run.tcl`
- Default config: `rtl/nvdla/syn/scripts/default_config.sh`
- Constraints: `rtl/nvdla/syn/cons/NV_NVDLA_partition_*.sdc`

The launcher copies RTL and include files into a build sandbox, then creates a VCS-style dependency file per module:

```text
-y <build>/src
+incdir+<build>/src
+libext+.v
+libext+.sv
+libext+.gv
+define+DISABLE_TESTPOINTS
+define+NV_SYNTHESIS
+define+RAM_INTERFACE
<module>.v
```

This project keeps the same define policy but points directly at `rtl/nvdla/vmod` instead of copying RTL into a sandbox.

The first `partition_m` DC elaborate run showed that `vmod/nvdla/car` is required for reset/synchronizer cells, and that DesignWare components such as `DW02_tree` and `DW_minmax` require `dw_foundation.sldb` in the DC link/synthetic library setup.

## Partition M

- Top: `NV_NVDLA_partition_m`
- RTL: `rtl/nvdla/vmod/nvdla/top/NV_NVDLA_partition_m.v`
- Main compute block: `NV_NVDLA_cmac`
- Instance: `u_NV_NVDLA_cmac`
- Constraint copied from: `rtl/nvdla/syn/cons/NV_NVDLA_partition_m.sdc`

Important top-level signals:

- Clock: `nvdla_core_clk`
- Resets: `direct_reset_`, `dla_reset_rstn`, internal `nvdla_core_rstn`
- Test/control: `test_mode`, `tmc2slcg_disable_clock_gating`, `global_clk_ovr_on`, `nvdla_clk_ovr_on`
- Config interface: `csb2cmac_a_req_*`, `cmac_a2csb_resp_*`
- Input datapath: `sc2mac_wt_*`, `sc2mac_dat_*`
- Output datapath toward accumulator: `mac_a2accu_*`, `mac_b2accu_*`

The reference SDC creates a 0.9 ns `nvdla_core_clk`, sets reset/test/control paths as false paths, and marks reset/test nets ideal. Treat 0.9 ns as a reference target, not a promised local-library timing goal.

## Partition A

- Top: `NV_NVDLA_partition_a`
- RTL: `rtl/nvdla/vmod/nvdla/top/NV_NVDLA_partition_a.v`
- Main compute block: `NV_NVDLA_cacc`
- Instance: `u_NV_NVDLA_cacc`
- Constraint copied from: `rtl/nvdla/syn/cons/NV_NVDLA_partition_a.sdc`

Partition A receives CMAC accumulator interfaces and emits CACC/SDP-facing outputs. It is the first reuse target after `partition_m` has a stable DC/PT/FM flow.

## Initial Execution Policy

1. Bring up `partition_m` with analyze/elaborate/link only.
2. Fix include, define, library, or unresolved-reference issues using the reference flow as the baseline.
3. Only after link is clean, add full DC synthesis and PT/Formality scripts.
