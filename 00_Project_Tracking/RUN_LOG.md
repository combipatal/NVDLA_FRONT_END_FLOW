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

## 2026-05-08 - PrimeTime STA, post-DFT scan netlist

- Command: `env PT_RUN_NAME=partition_m_4p0ns_dftcg_const_reset_scan_sta NETLIST=4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/net/NV_NVDLA_partition_m.scan.vg SDC_FILE=4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/net/NV_NVDLA_partition_m.scan.sdc SDF_FILE=4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/net/NV_NVDLA_partition_m.scan.sdf 3_sta/scripts/run_one_pt.sh NV_NVDLA_partition_m partition_m_4p0ns_dftcg_const_reset_dft`
- Stage: STA
- Result: `PASS_WITH_NOTE`
- Input artifacts:
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/net/NV_NVDLA_partition_m.scan.vg`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/net/NV_NVDLA_partition_m.scan.sdc`
- Output artifacts:
  - Reports under `3_sta/4_report/partition_m_4p0ns_dftcg_const_reset_scan_sta`
  - Session under `3_sta/2_output/partition_m_4p0ns_dftcg_const_reset_scan_sta`
- Key reports:
  - `3_sta/4_report/partition_m_4p0ns_dftcg_const_reset_scan_sta/NV_NVDLA_partition_m.pt.qor.rpt`
  - `3_sta/4_report/partition_m_4p0ns_dftcg_const_reset_scan_sta/NV_NVDLA_partition_m.pt.global_timing.rpt`
  - `3_sta/4_report/partition_m_4p0ns_dftcg_const_reset_scan_sta/NV_NVDLA_partition_m.pt.constraint.rpt`
- Pass/fail evidence:
  - Setup path group `nvdla_core_clk` WNS `+0.0360 ns`, TNS `0.0000`, violating paths `0`.
  - No setup violations found in global timing.
- Warnings or violations:
  - Async hold/removal WNS `-0.0345 ns`, TNS `-77.7515`, violating paths `2383`.
  - Max capacitance count `15258`.
  - Max transition count `912`.
- Waiver/defer reason:
  - Hold/removal and max transition/capacitance cleanup are backend-deferred to CTS/route/fix-hold and physical optimization.
- Next action:
  - Run Formality R2N/N2N and ATPG.

## 2026-05-08 - Formality R2N setup and compare, DFT synthesis build

- Command: `env FM_RUN_NAME=partition_m_4p0ns_dftcg_r2n 5_formality/scripts/run_one_fm.sh r2n NV_NVDLA_partition_m`
- Stage: Formality R2N
- Result: `FAIL`
- Input artifacts:
  - `2_synthesis/1_input/filelists/NV_NVDLA_partition_m.dft.f`
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/db/NV_NVDLA_partition_m.ddc`
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/fv/NV_NVDLA_partition_m.svf`
  - DesignWare models `DW_minmax.v` and `DW02_tree.v`
- Output artifacts:
  - Reports under `5_formality/4_report/partition_m_4p0ns_dftcg_r2n`
  - Log `5_formality/3_log/partition_m_4p0ns_dftcg_r2n/NV_NVDLA_partition_m.r2n.fm.log`
- Key reports:
  - `5_formality/4_report/partition_m_4p0ns_dftcg_r2n/NV_NVDLA_partition_m.fm.match.rpt`
  - `5_formality/4_report/partition_m_4p0ns_dftcg_r2n/NV_NVDLA_partition_m.fm.verify.rpt`
- Pass/fail evidence:
  - Final R2N verification `FAILED`.
  - Passing compare points: `1587`.
  - Failing compare points: `282276`.
  - Aborted compare points: `0`.
  - Unverified compare points: `67046`.
- Warnings or violations:
  - Initial R2N attempt failed because `DW_minmax` and `DW02_tree` were unresolved in the RTL reference.
  - Script was fixed by reading DesignWare Verilog models before reading the RTL filelist.
  - Second R2N setup attempt failed because implementation DDC was read before the reference top was linked; script order was fixed.
  - Final R2N still fails with large reference-side unmatched/black-box points and missing `guide_hier_map` guidance.
- Waiver/defer reason:
  - Not waived for signoff. R2N requires a stronger DC Formality setup, likely enabling hierarchical guidance such as `hdlin_enable_hier_map` and `set_verification_top`, plus resolving reference black-box modeling.
- Next action:
  - Use N2N as the post-DFT equivalence check for this milestone and improve R2N setup later.

## 2026-05-08 - Formality N2N, pre-scan DDC to post-DFT scan DDC

- Command: `env FM_RUN_NAME=partition_m_4p0ns_dftcg_const_reset_n2n 5_formality/scripts/run_one_fm.sh n2n NV_NVDLA_partition_m`
- Stage: Formality N2N
- Result: `PASS_WITH_NOTE`
- Input artifacts:
  - `2_synthesis/2_output/partition_m_4p0ns_dftcg/db/NV_NVDLA_partition_m.ddc`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/db/NV_NVDLA_partition_m.scan.ddc`
  - `5_formality/scripts/run_fm_n2n.tcl`
- Output artifacts:
  - Reports under `5_formality/4_report/partition_m_4p0ns_dftcg_const_reset_n2n`
  - Log `5_formality/3_log/partition_m_4p0ns_dftcg_const_reset_n2n/NV_NVDLA_partition_m.n2n.fm.log`
- Key reports:
  - `5_formality/4_report/partition_m_4p0ns_dftcg_const_reset_n2n/NV_NVDLA_partition_m.fm.match.rpt`
  - `5_formality/4_report/partition_m_4p0ns_dftcg_const_reset_n2n/NV_NVDLA_partition_m.fm.verify.rpt`
- Pass/fail evidence:
  - Final N2N verification `SUCCEEDED`.
  - Passing compare points: `68653`.
  - Failing compare points: `0`.
  - Matched DFF compare points: `67183`.
- Warnings or violations:
  - First N2N setup attempt failed because implementation DDC was read before the reference top was linked; script order was fixed.
  - Second N2N attempt failed with `20` failing compare points on `cfg_is_fp16*` registers because `test_mode` and `tmc2slcg_disable_clock_gating` were constrained only on the implementation side.
  - Script was fixed to constrain scan-only ports on implementation and functional test ports on both reference and implementation.
  - Remaining unmatched implementation ports are expected scan insertion ports: 33 inputs and 31 outputs.
- Waiver/defer reason:
  - Scan-only port mismatch is expected for pre-scan-vs-post-scan N2N and does not block functional-mode post-DFT equivalence.
- Next action:
  - Run TetraMAX ATPG.

## 2026-05-08 - TetraMAX stuck-at ATPG

- Command: `env ATPG_RUN_NAME=partition_m_4p0ns_dftcg_const_reset_atpg 4_dft/scripts/run_one_tmax.sh NV_NVDLA_partition_m partition_m_4p0ns_dftcg_const_reset_dft`
- Stage: ATPG
- Result: `PASS_WITH_NOTE`
- Input artifacts:
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/net/NV_NVDLA_partition_m.scan.vg`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_dft/test/NV_NVDLA_partition_m.scan.spf`
  - `/DATA/home/edu135/aes128_core/SAED32_EDK/lib/stdcell_rvt/verilog/saed32nm.v`
- Output artifacts:
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_atpg/NV_NVDLA_partition_m.stuck.stil`
  - `4_dft/2_output/partition_m_4p0ns_dftcg_const_reset_atpg/NV_NVDLA_partition_m.stuck.faults`
- Key reports:
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_atpg/NV_NVDLA_partition_m.tmax.summary.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_atpg/NV_NVDLA_partition_m.tmax.fault_summary.rpt`
  - `4_dft/4_report/partition_m_4p0ns_dftcg_const_reset_atpg/NV_NVDLA_partition_m.tmax.pattern_summary.rpt`
- Pass/fail evidence:
  - TetraMAX DRC: no violations occurred during DRC process.
  - Total faults: `7934572`.
  - Detected faults: `7869299`.
  - Possibly detected faults: `1`.
  - Undetectable faults: `58119`.
  - ATPG untestable faults: `12`.
  - Not detected faults: `7141`.
  - Test coverage: `99.91%`.
  - Generated basic-scan patterns: `14836`.
- Warnings or violations:
  - First ATPG attempt failed because TetraMAX does not accept `.db` as a `read_netlist -library` input and therefore could not resolve `SDFFARX1_RVT`.
  - Script was fixed to use the SAED32 RVT Verilog stdcell library.
  - Final ATPG log still prints a prior-rule notice for `N20`; final DRC summary reports no violations.
- Waiver/defer reason:
  - Remaining `ND` faults and reset assertion coverage are not closed by this milestone.
  - Max transition/capacitance cleanup remains backend-deferred.
- Next action:
  - Commit scripts and tracking updates.
