# Project Status

## Snapshot

- Date: 2026-05-08 KST
- Active design: `NV_NVDLA_partition_m`
- Active functional synthesis run: `partition_m_4p0ns`
- Active DFT synthesis run: `partition_m_4p0ns_dftcg`
- Active Formality R2N debug synthesis run: `partition_m_4p0ns_dftcg_ghm`
- Active DFT insertion run: `partition_m_4p0ns_dftcg_const_reset_dft`
- Active clock period: `4.0 ns`
- Repository layout follows numbered stages: `1_vcs`, `2_synthesis`, `3_sta`, `4_dft`, `5_formality`, `6_sweep`.

## AGENTS.md Operating Rule

`AGENTS.md` requires every completed tool run to be recorded in:

- `00_Project_Tracking/RUN_LOG.md`
- `00_Project_Tracking/RESULT_SUMMARY.md`
- `00_Project_Tracking/PROJECT_STATUS.md`

Generated tool outputs, logs, reports, and work directories stay ignored by git. Track scripts, constraints, filelists, wrappers, configs, project documentation, curated summaries, and decision records.

## Current Technical State

- Functional 4.0 ns topographical synthesis passes setup in DC.
- PT setup is clean at 4.0 ns.
- PT hold/removal violations are deferred to backend.
- Initial DFT insertion on the functional clock-gated DDC failed due NVDLA SLCG clock-gating test-enable behavior.
- DFT-specific synthesis using `VLIB_BYPASS_POWER_CG` removes the DFT D9 clock-port-not-active issue in pre-check.
- `dla_reset_rstn` is held inactive as `Constant 1` during scan because the same reset port also feeds the reset synchronizer data path.
- Full DFT insertion from `partition_m_4p0ns_dftcg_const_reset_dft` completes with 32 scan chains and post-DFT DRC total violations `0`.
- Scan-netlist STA setup is clean; async hold/removal is backend-deferred.
- Formality R2N is still failing, but the root cause is narrower than before:
  - DC now emits `guide_hier_map` guidance through `hdlin_enable_hier_map` and `set_verification_top`.
  - GHM R2N accepts `32` `hier_map` guidance commands.
  - The default fallback R2N reference filelist uses `SYNTHESIS` and `DESIGNWARE_NOEXIST` to use NVDLA DW fallback RTL and suppress simulation-only sync randomizer code.
  - The fallback setup reduced reference black-boxes from `2154` to `2` and unmatched compare points from `282416` to `32`.
  - R2N still fails on matched CMAC MAC5 carry-save tree DFF compare points, so it is not signoff-clean.
  - A debug run with `FM_FAILING_POINT_LIMIT=200` reached `200` failing points; the first `200` failures are all under `u_NV_NVDLA_cmac/u_core/u_mac_5`.
  - A debug run with `FM_DONT_VERIFY_FILE=5_formality/1_input/dont_verify/NV_NVDLA_partition_m.r2n.cmac_mac5_pp_debug.lst` excluded `1152` MAC5 `pp_out_l0n*` DFF compare points, but the first `200` failures moved to `u_NV_NVDLA_cmac/u_core/u_mac_4`.
  - `analyze_points` on the baseline failing points found `11` unmatched cone inputs, `1` rejected guidance command, and `94` required inputs. The rejected guidance command is `reg_constant`.
  - `5_formality/scripts/run_fm_r2n.tcl` now supports `FM_FAILING_POINT_LIMIT` for failure-depth debug, `FM_DONT_VERIFY_FILE` for scoped `set_dont_verify_points` experiments, and `FM_ANALYZE_POINTS`/`FM_ANALYZE_LIMIT` for optional Formality root-cause analysis reports.
  - Direct Synopsys DWROOT mode is available with `FM_USE_DWROOT=1`, but the first run was deferred after a long verification-model build and `FM-424` DW02 tree warnings.
- `DW02_tree` is a Synopsys DesignWare module used in the CMAC MAC datapath to compress multiple partial-product vectors into two carry-save outputs. The current R2N failure is interpreted as a reference-modeling mismatch around this carry-save representation, not as a DFT or timing failure.
- Formality N2N passes from pre-scan DDC to post-DFT scan DDC in functional mode.
- TetraMAX stuck-at ATPG completes with DRC clean and test coverage `99.91%`.

## Open Items

- Finish Formality R2N setup. Current focus is deterministic `DW02_tree`/carry-save modeling while keeping GHM guidance active.
- Improve DC/Formality guidance around CMAC MAC datapath constants. The next target is rejected `reg_constant` guidance, because Formality `analyze_points` reports it as a likely contributor to the failing partial-product compare points.
- Decide whether the remaining `first_stage_of_sync` placeholder black-boxes should be modeled explicitly or treated as benign placeholders.
- Backend must fix or re-characterize max transition/capacitance violations.
- Define a separate reset-test strategy if `dla_reset_rstn` assertion coverage is required.
- Decide whether current TetraMAX `ND` faults need more ATPG effort, constraints, or classification.
- Reuse the flow for additional partitions after `partition_m` stabilizes.
