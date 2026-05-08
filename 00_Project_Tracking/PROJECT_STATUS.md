# Project Status

## Snapshot

- Date: 2026-05-08 KST
- Active design: `NV_NVDLA_partition_m`
- Active functional synthesis run: `partition_m_4p0ns`
- Active DFT synthesis run: `partition_m_4p0ns_dftcg`
- Active Formality R2N/timing synthesis candidate: `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b`
- Active DFT insertion run: `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_dft`
- Active clock period: `4.0 ns`
- Repository layout follows numbered stages: `1_vcs`, `2_synthesis`, `3_sta`, `4_dft`, `5_formality`, `6_sweep`.
- Frontend final report: `00_Project_Tracking/FRONTEND_FINAL_REPORT.md`

## AGENTS.md Operating Rule

`AGENTS.md` requires every completed tool run to be recorded in:

- `00_Project_Tracking/RUN_LOG.md`
- `00_Project_Tracking/RESULT_SUMMARY.md`
- `00_Project_Tracking/PROJECT_STATUS.md`

Generated tool outputs, logs, reports, and work directories stay ignored by git. Track scripts, constraints, filelists, wrappers, configs, project documentation, curated summaries, and decision records.

Exception recorded on 2026-05-08: generated scripts and reports are tracked in git by explicit user request. Long generated logs and generated implementation outputs such as DDC, netlist, SDF, SPF, STIL, and fault databases remain ignored unless separately requested.

## Current Technical State

- Functional 4.0 ns topographical synthesis passes setup in DC.
- PT setup is clean at 4.0 ns.
- PT hold/removal violations are deferred to backend.
- Initial DFT insertion on the functional clock-gated DDC failed due NVDLA SLCG clock-gating test-enable behavior.
- DFT-specific synthesis using `VLIB_BYPASS_POWER_CG` removes the DFT D9 clock-port-not-active issue in pre-check.
- `dla_reset_rstn` is held inactive as `Constant 1` during scan because the same reset port also feeds the reset synchronizer data path.
- Full DFT insertion from `partition_m_4p0ns_dftcg_const_reset_dft` completes with 32 scan chains and post-DFT DRC total violations `0`.
- VP8b-based full DFT insertion from `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_dft` also completes with 32 scan chains and post-DFT DRC total violations `0`.
- Scan-netlist STA setup is clean; async hold/removal is backend-deferred.
- Formality R2N root cause has been isolated and fixed in a debug build:
  - DC now emits `guide_hier_map` guidance through `hdlin_enable_hier_map` and `set_verification_top`.
  - GHM R2N accepts `32` `hier_map` guidance commands.
  - The default fallback R2N reference filelist uses `SYNTHESIS` and `DESIGNWARE_NOEXIST` to use NVDLA DW fallback RTL and suppress simulation-only sync randomizer code.
  - The fallback setup reduced reference black-boxes from `2154` to `2` and unmatched compare points from `282416` to `32`.
  - The SVF rejected-guidance report showed `32` rejected `reg_constant` operations and `174` rejected `multiplier` operations on the `partition_m_4p0ns_dftcg_ghm` baseline.
  - Re-synthesis with `DC_HDLIN_VERIFICATION_PRIORITY=1` and CMAC high verification priority produced `partition_m_4p0ns_dftcg_ghm_vp2`.
  - The VP2 R2N run fixed the previous unmatched compare points: `0(0)` unmatched reference/implementation compare points.
  - The VP2 R2N run also fixed the rejected `reg_constant` issue: `reg_constant` accepted `27`, rejected `0`.
  - VP2 still failed on matched CMAC carry-save tree DFF compare points, first reported under `u_NV_NVDLA_cmac/u_core/u_mac_3/pp_out_l0n03_0_d1_reg_*`.
  - The strongest clue was rejected `multiplier` guidance: VP2 reports `multiplier` accepted `0`, rejected `270`, mostly for CMAC `DW02_tree`/carry-save cells such as `u_tree_l4n*`, `u_tree_l3n*`, and `u_tree_sign_l*`.
  - The root cause was a DC/Formality reference-model mismatch: VP2 DC synthesized the CMAC arithmetic from Synopsys `DW02_tree`, while the fast Formality R2N reference used `DESIGNWARE_NOEXIST` and therefore instantiated NVDLA fallback `NV_DW02_tree`.
  - `2_synthesis/1_input/filelists/NV_NVDLA_partition_m.dft.nvdw.f` was added to force the same `DESIGNWARE_NOEXIST` fallback model into DC for debug.
  - VP3 synthesis `partition_m_4p0ns_dftcg_ghm_vp3_nvdw` completed and generated DDC/netlist/SVF, but is timing-failing at 4.0 ns with critical path slack `-0.2117 ns`.
  - VP3 R2N `partition_m_4p0ns_dftcg_ghm_vp3_nvdw_r2n` passed: `Verification SUCCEEDED`, `68301` passing compare points, `0` failing/aborted/unverified, total SVF guidance accepted `10872`, rejected `0`.
  - VP4/VP5/VP6 swept compile-clock overconstraint while restoring final reporting to `4.0 ns`; VP5 was closest but still failed setup with WNS `-0.0264 ns`, TNS `-5.7297 ns`, and `538` violating paths.
  - `2_synthesis/scripts/run_dc.tcl` now supports `DC_COMPILE_CLK_PERIOD` separately from `DC_CLK_PERIOD`, plus optional `DC_FINAL_INCREMENTAL_COMPILE=1`.
  - VP7 used compile period `3.6 ns`, restored `4.0 ns` for reporting/writeout, and ran final incremental compile. It reached setup slack `+0.0016 ns`, TNS `0`, and hold clean at `4.0 ns`.
  - VP7 R2N failed one compare point, `u_NV_NVDLA_cmac/u_core/u_mac_1/mac_out_data_reg_85_`, even though SVF guidance was fully accepted.
  - VP7 `analyze_points` showed an implementation-only cone input from a set/reset scan flop mapping. The VP7 netlist mapped that bit to `SDFFSSRX1_RVT`; the RTL reference did not have the equivalent set/reset cone.
  - `2_synthesis/scripts/run_dc.tcl` now supports `DC_DONT_USE_FM_RISKY_SCAN_FLOPS=1`, which marks `SDFFSSRX*_RVT` library cells `dont_use`.
  - The first VP8 attempt was invalid because `set_dont_use $risky_scan_flops true` is not valid DC syntax; it was fixed to `set_dont_use $risky_scan_flops`.
  - VP8b `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b` is the current best synthesis candidate: final `nvdla_core_clk` is `4.00 ns`, setup slack is `+0.0008 ns`, TNS `0`, violating paths `0`, and hold is clean.
  - VP8b netlist search found no `SDFFSSRX` usage and `mac_out_data_reg_85_` instances are plain `SDFFX1_RVT`/`SDFFX2_RVT`.
  - VP8b R2N `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_r2n` passed: `Verification SUCCEEDED`, `68301` passing compare points, `0` failing/aborted/unverified, total SVF guidance accepted `10885`, rejected `0`.
  - VP8b DFT insertion `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_dft` passed post-DFT DRC with total violations `0`, 32 scan chains, chain lengths `2088-2089`, and post-DFT setup slack `+0.0008 ns`.
  - VP8b scan-netlist STA `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_scan_sta` passed setup: `nvdla_core_clk` setup WNS `+0.0128 ns`, TNS `0`, setup violations `0`.
  - VP8b scan-netlist STA still has async removal violations: WNS `-0.0315 ns`, TNS `-71.0320 ns`, `2383` paths. This remains backend-deferred.
  - VP8b N2N `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_n2n` passed: `Verification SUCCEEDED`, `68301` passing, `0` failing/aborted/unverified. The `64` implementation-only unmatched objects are scan-only ports/points.
  - VP8b TetraMAX ATPG `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_atpg` completed with ATPG DRC clean, stuck-at coverage `99.81%`, and `20317` basic-scan patterns.
  - `5_formality/scripts/run_fm_r2n.tcl` now reports rejected `uniquify` and `ununiquify` guidance in addition to `reg_constant` and `multiplier`.
  - A debug run with `FM_FAILING_POINT_LIMIT=200` reached `200` failing points; the first `200` failures are all under `u_NV_NVDLA_cmac/u_core/u_mac_5`.
  - A debug run with `FM_DONT_VERIFY_FILE=5_formality/1_input/dont_verify/NV_NVDLA_partition_m.r2n.cmac_mac5_pp_debug.lst` excluded `1152` MAC5 `pp_out_l0n*` DFF compare points, but the first `200` failures moved to `u_NV_NVDLA_cmac/u_core/u_mac_4`.
  - `analyze_points` on the baseline failing points found `11` unmatched cone inputs, `1` rejected guidance command, and `94` required inputs. The rejected guidance command is `reg_constant`.
  - `5_formality/scripts/run_fm_r2n.tcl` now supports `FM_FAILING_POINT_LIMIT` for failure-depth debug, `FM_DONT_VERIFY_FILE` for scoped `set_dont_verify_points` experiments, and `FM_ANALYZE_POINTS`/`FM_ANALYZE_LIMIT` for optional Formality root-cause analysis reports.
  - Direct Synopsys DWROOT mode is available with `FM_USE_DWROOT=1`, but the first run was deferred after a long verification-model build and `FM-424` DW02 tree warnings.
- `DW02_tree` is a Synopsys DesignWare module used in the CMAC MAC datapath to compress multiple partial-product vectors into two carry-save outputs. The observed R2N failure was a reference-modeling mismatch around this carry-save representation, not a DFT failure.
- Formality N2N passes from pre-scan DDC to post-DFT scan DDC in functional mode for both the earlier const-reset path and the VP8b path.
- TetraMAX stuck-at ATPG completes with DRC clean. The earlier const-reset path has test coverage `99.91%`; the VP8b path has test coverage `99.81%`.
- Frontend final report has been created at `00_Project_Tracking/FRONTEND_FINAL_REPORT.md`.
- Generated reports are now included in git tracking by explicit user request; long generated logs remain ignored.
- Report-only git tracking has been pushed in commit `7594062`; `415` generated `4_report` files are tracked, while generated `3_log` directories track only `.gitkeep` placeholders.
- GitHub accepted the push but warned that two Formality match reports are `55.82 MB`, above the recommended `50 MB` file-size limit.

## Open Items

- Decide whether the VP8b ATPG coverage delta (`99.81%` vs previous `99.91%`) requires additional ATPG effort, fault classification, or is acceptable for the current milestone.
- Decide whether the remaining `first_stage_of_sync` placeholder black-boxes should be modeled explicitly or treated as benign placeholders.
- Backend must fix or re-characterize max transition/capacitance violations.
- Clean up the SDC/check_timing model: `TIM-216` input delays without `-clock` and 1445 unconstrained max-delay endpoints remain.
- Define a separate reset-test strategy if `dla_reset_rstn` assertion coverage is required.
- Decide whether current TetraMAX `ND` faults need more ATPG effort, constraints, or classification.
- Reuse the flow for additional partitions after `partition_m` stabilizes.
