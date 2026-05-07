# Project Status

## Snapshot

- Date: 2026-05-08 KST
- Active design: `NV_NVDLA_partition_m`
- Active functional synthesis run: `partition_m_4p0ns`
- Active DFT synthesis run: `partition_m_4p0ns_dftcg`
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

## Open Items

- Run STA on scan netlist after full DFT insertion.
- Add Formality flow for RTL-to-netlist comparison.
- Categorize or fix post-DFT max transition/capacitance violations.
- Define a separate reset-test strategy if `dla_reset_rstn` assertion coverage is required.
- Reuse the flow for additional partitions after `partition_m` stabilizes.
