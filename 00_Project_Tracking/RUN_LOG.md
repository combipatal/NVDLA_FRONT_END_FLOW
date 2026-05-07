# Run Log

## 2026-05-07 - DC topo synthesis, functional 4.0 ns

- Command: `env DC_CLK_PERIOD=4.0 DC_RUN_NAME=partition_m_4p0ns 2_synthesis/scripts/run_one_dc.sh NV_NVDLA_partition_m`
- Stage: Synthesis
- Result: `PASS_WITH_NOTE`
- Input artifacts:
  - `2_synthesis/1_input/filelists/NV_NVDLA_partition_m.f`
  - `2_synthesis/1_input/constraints/NV_NVDLA_partition_m.sdc`
- Output artifacts:
  - `2_synthesis/2_output/partition_m_4p0ns/db/NV_NVDLA_partition_m.ddc`
  - `2_synthesis/2_output/partition_m_4p0ns/net/NV_NVDLA_partition_m.vg`
  - `2_synthesis/2_output/partition_m_4p0ns/net/NV_NVDLA_partition_m.sdc`
  - `2_synthesis/2_output/partition_m_4p0ns/net/NV_NVDLA_partition_m.sdf`
- Key reports:
  - `2_synthesis/4_report/partition_m_4p0ns/NV_NVDLA_partition_m.qor.rpt`
  - `2_synthesis/4_report/partition_m_4p0ns/NV_NVDLA_partition_m.timing.rpt`
  - `2_synthesis/4_report/partition_m_4p0ns/NV_NVDLA_partition_m.constraint.rpt`
- Pass/fail evidence:
  - DC QoR WNS `+0.0117 ns`
  - TNS `0.0000`
  - Violating paths `0`
- Warnings or violations:
  - Max transition violations: `911`
  - Max capacitance violations: `2044`
- Waiver/defer reason:
  - DRC cleanup is deferred to backend sizing/buffering and physical implementation.
- Next action:
  - Run STA and DFT on the 4.0 ns synthesis result.

## 2026-05-07 - PrimeTime STA, functional 4.0 ns synthesis

- Command: `3_sta/scripts/run_one_pt.sh NV_NVDLA_partition_m partition_m_4p0ns`
- Stage: STA
- Result: `PASS_WITH_NOTE`
- Input artifacts:
  - `2_synthesis/2_output/partition_m_4p0ns/net/NV_NVDLA_partition_m.vg`
  - `2_synthesis/2_output/partition_m_4p0ns/net/NV_NVDLA_partition_m.sdc`
- Output artifacts:
  - STA reports under `3_sta/4_report/partition_m_4p0ns`
- Key reports:
  - `3_sta/4_report/partition_m_4p0ns/NV_NVDLA_partition_m.timing.setup.rpt`
  - `3_sta/4_report/partition_m_4p0ns/NV_NVDLA_partition_m.timing.hold.rpt`
  - `3_sta/4_report/partition_m_4p0ns/NV_NVDLA_partition_m.constraint.rpt`
- Pass/fail evidence:
  - Setup WNS `+0.0304 ns`
  - Setup TNS `0.0000`
- Warnings or violations:
  - Hold/removal default async path WNS `-0.0358 ns`, TNS `-81.5467`, violating paths `2417`
  - PT DRC includes max capacitance and max transition violations.
- Waiver/defer reason:
  - Hold/removal and physical DRC cleanup are deferred to backend CTS/route/fix-hold.
- Next action:
  - Continue DFT with hold cleanup explicitly deferred.

## 2026-05-07 - DFT insertion, functional 4.0 ns synthesis

- Command: `DFT_RUN_NAME=partition_m_4p0ns_dft 4_dft/scripts/run_one_dft.sh NV_NVDLA_partition_m partition_m_4p0ns`
- Stage: DFT
- Result: `FAIL`
- Input artifacts:
  - `2_synthesis/2_output/partition_m_4p0ns/db/NV_NVDLA_partition_m.ddc`
  - `2_synthesis/1_input/constraints/NV_NVDLA_partition_m.sdc`
- Output artifacts:
  - `4_dft/2_output/partition_m_4p0ns_dft/db/NV_NVDLA_partition_m.scan.ddc`
  - `4_dft/2_output/partition_m_4p0ns_dft/net/NV_NVDLA_partition_m.scan.vg`
  - `4_dft/2_output/partition_m_4p0ns_dft/test/NV_NVDLA_partition_m.scan.spf`
- Key reports:
  - `4_dft/4_report/partition_m_4p0ns_dft/NV_NVDLA_partition_m.dft_drc.pre_dft.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dft/NV_NVDLA_partition_m.dft_drc.post_dft.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dft/NV_NVDLA_partition_m.scan_path.rpt`
- Pass/fail evidence:
  - Pre-DFT DRC total violations: `68264`
  - Post-DFT DRC total violations: `67137`
  - Scan chains contained only about 108 total cells, not the expected full scan population.
- Warnings or violations:
  - Pre-DFT D9 clock-port-not-active violations: `67135`
  - Post-DFT S19 nonscan disturbed violations: `67135`
- Waiver/defer reason:
  - Not waived. Root cause is NVDLA clock-gating wrapper tying `CKLNQD12.TE` to constant `1'b0`, preventing scan shift clock activation through gated clocks.
- Next action:
  - Use DFT-specific synthesis with `VLIB_BYPASS_POWER_CG`.

## 2026-05-08 - DC topo synthesis, DFT clock-gating bypass 4.0 ns

- Command: `env DC_FILELIST=2_synthesis/1_input/filelists/NV_NVDLA_partition_m.dft.f DC_CLK_PERIOD=4.0 DC_RUN_NAME=partition_m_4p0ns_dftcg 2_synthesis/scripts/run_one_dc.sh NV_NVDLA_partition_m`
- Stage: Synthesis
- Result: `PASS_WITH_NOTE`
- Input artifacts:
  - `2_synthesis/1_input/filelists/NV_NVDLA_partition_m.dft.f`
  - `2_synthesis/1_input/constraints/NV_NVDLA_partition_m.sdc`
- Output artifacts:
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/db/NV_NVDLA_partition_m.ddc`
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/net/NV_NVDLA_partition_m.vg`
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/net/NV_NVDLA_partition_m.sdc`
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/net/NV_NVDLA_partition_m.sdf`
- Key reports:
  - `2_synthesis/4_report/partition_m_4p0ns_dftcg/NV_NVDLA_partition_m.qor.rpt`
  - `2_synthesis/4_report/partition_m_4p0ns_dftcg/NV_NVDLA_partition_m.check_design.rpt`
- Pass/fail evidence:
  - DC QoR WNS `+0.0031 ns`
  - TNS `0.0000`
  - Violating paths `0`
- Warnings or violations:
  - Max transition violations: `907`
  - Max capacitance violations: `2007`
  - `LINT-60` unloaded/unconnected pins are present after clock-gating bypass and optimization.
- Waiver/defer reason:
  - DFT bypass is a front-end scan enablement build, not the functional implementation netlist.
  - Max transition/cap cleanup remains backend-deferred.
- Next action:
  - Run DFT insertion from `partition_m_4p0ns_dftcg`.

## 2026-05-08 - DFT pre-check, DFT clock-gating bypass synthesis

- Command: `DFT_INSERT=0 DFT_RUN_NAME=partition_m_4p0ns_dftcg_probe 4_dft/scripts/run_one_dft.sh NV_NVDLA_partition_m partition_m_4p0ns_dftcg`
- Stage: DFT
- Result: `PASS_WITH_NOTE`
- Input artifacts:
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/db/NV_NVDLA_partition_m.ddc`
  - `2_synthesis/1_input/constraints/NV_NVDLA_partition_m.sdc`
- Output artifacts:
  - Reports under `4_dft/4_report/partition_m_4p0ns_dftcg_probe`
- Key reports:
  - `4_dft/4_report/partition_m_4p0ns_dftcg_probe/NV_NVDLA_partition_m.dft_drc.pre_dft.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_probe/NV_NVDLA_partition_m.preview_dft.rpt`
- Pass/fail evidence:
  - D9 clock-port-not-active violations reduced from `67135` to `0`
  - Sequential cells with violations: `0 out of 67183`
  - Preview shows 32 chains of about `2099-2100` cells each.
- Warnings or violations:
  - `TEST-332` unconnected input pin violations: `1138`
  - D8 reset capture violation: `1`
  - D10 reset clock-feeding-data violation: `1`
- Waiver/defer reason:
  - D8/D10 are reset/async test modeling issues; classify separately before signoff.
  - TEST-332 unconnected pins need either top-level tie-off policy or explicit waiver.
- Next action:
  - Run full DFT insertion and record post-DFT DRC.

## 2026-05-08 - Full DFT insertion, DFT clock-gating bypass synthesis

- Command: `DFT_RUN_NAME=partition_m_4p0ns_dftcg_dft 4_dft/scripts/run_one_dft.sh NV_NVDLA_partition_m partition_m_4p0ns_dftcg`
- Stage: DFT
- Result: `PASS_WITH_NOTE`
- Input artifacts:
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/db/NV_NVDLA_partition_m.ddc`
  - `2_synthesis/1_input/constraints/NV_NVDLA_partition_m.sdc`
- Output artifacts:
  - `4_dft/2_output/partition_m_4p0ns_dftcg_dft/db/NV_NVDLA_partition_m.scan.ddc`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_dft/net/NV_NVDLA_partition_m.scan.vg`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_dft/net/NV_NVDLA_partition_m.scan.sdc`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_dft/net/NV_NVDLA_partition_m.scan.sdf`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_dft/test/NV_NVDLA_partition_m.scan.spf`
- Key reports:
  - `4_dft/4_report/partition_m_4p0ns_dftcg_dft/NV_NVDLA_partition_m.dft_drc.post_dft.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_dft/NV_NVDLA_partition_m.scan_path.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_dft/NV_NVDLA_partition_m.qor.post_dft.rpt`
- Pass/fail evidence:
  - Post-DFT DRC total violations reduced to `2`
  - S19 nonscan disturbed violations reduced from `67135` to `0`
  - Sequential cells with violations: `0 out of 67183`
  - Scan path report shows 32 chains, lengths `2099-2100`
  - Post-DFT QoR WNS `+0.0031 ns`, TNS `0.0000`, violating paths `0`
- Warnings or violations:
  - C4 reset capture violation: `1`
  - C26 reset-as-data-different-from-capture-clock violation: `1`
  - Max transition violations: `912`
  - Max capacitance violations: `2064`
- Waiver/defer reason:
  - C4/C26 are reset/test protocol issues and are not waived for signoff.
  - Max transition/cap cleanup remains backend-deferred.
- Next action:
  - Decide reset DFT protocol handling for `dla_reset_rstn`, then run scan-netlist STA.

## 2026-05-08 - DFT pre-check, reset constant protocol

- Command: `env DFT_INSERT=0 DFT_RUN_NAME=partition_m_4p0ns_dftcg_const_reset_probe 4_dft/scripts/run_one_dft.sh NV_NVDLA_partition_m partition_m_4p0ns_dftcg`
- Stage: DFT
- Result: `PASS_WITH_NOTE`
- Input artifacts:
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/db/NV_NVDLA_partition_m.ddc`
  - `2_synthesis/1_input/constraints/NV_NVDLA_partition_m.sdc`
  - `4_dft/scripts/run_dft.tcl`
- Output artifacts:
  - Reports under `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_probe`
- Key reports:
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_probe/NV_NVDLA_partition_m.dft_signal.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_probe/NV_NVDLA_partition_m.dft_drc.pre_dft.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_probe/NV_NVDLA_partition_m.preview_dft.rpt`
- Pass/fail evidence:
  - `dla_reset_rstn` is modeled as `Constant 1` during scan protocol.
  - D8/D10 reset synchronizer violations reduced to `0`.
  - Sequential cells with violations: `0 out of 67183`.
- Warnings or violations:
  - Pre-DFT `TEST-332` unconnected input pin violations: `1138`.
- Waiver/defer reason:
  - `TEST-332` is from open partition-boundary inputs in the current partition-level DFT model and is cleared after insertion for this run.
  - Reset assertion coverage for `dla_reset_rstn` is not claimed by this scan protocol; it is held inactive during scan.
- Next action:
  - Run full DFT insertion with the reset constant protocol.

## 2026-05-08 - Full DFT insertion, reset constant protocol

- Command: `env DFT_RUN_NAME=partition_m_4p0ns_dftcg_const_reset_dft 4_dft/scripts/run_one_dft.sh NV_NVDLA_partition_m partition_m_4p0ns_dftcg`
- Stage: DFT
- Result: `PASS_WITH_NOTE`
- Input artifacts:
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/db/NV_NVDLA_partition_m.ddc`
  - `2_synthesis/1_input/constraints/NV_NVDLA_partition_m.sdc`
  - `4_dft/scripts/run_dft.tcl`
- Output artifacts:
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/db/NV_NVDLA_partition_m.scan.ddc`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/net/NV_NVDLA_partition_m.scan.vg`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/net/NV_NVDLA_partition_m.scan.sdc`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/net/NV_NVDLA_partition_m.scan.sdf`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/test/NV_NVDLA_partition_m.scan.spf`
- Key reports:
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_dft/NV_NVDLA_partition_m.dft_drc.pre_dft.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_dft/NV_NVDLA_partition_m.dft_drc.post_dft.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_dft/NV_NVDLA_partition_m.scan_path.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_dft/NV_NVDLA_partition_m.qor.post_dft.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_dft/NV_NVDLA_partition_m.constraint.post_dft.rpt`
- Pass/fail evidence:
  - Post-DFT DRC total violations: `0`.
  - Sequential cells with violations: `0 out of 67183`.
  - Scan path report shows 32 chains, lengths `2099-2100`.
  - Post-DFT QoR WNS `0.0000 ns`, TNS `0.0000`, violating paths `0`.
  - Design area `3031603.2076`.
- Warnings or violations:
  - Pre-DFT `TEST-332` unconnected input pin violations: `1138`.
  - Post-DFT max transition/capacitance violations remain in `constraint.post_dft.rpt`.
- Waiver/defer reason:
  - `dla_reset_rstn` is intentionally held inactive during scan to avoid reset synchronizer capture protocol violations.
  - Max transition/cap cleanup remains backend-deferred.
- Next action:
  - Run STA on the scan netlist and add Formality flow.
