# Result Summary

## Frontend Closure Summary

- Status: `CLOSED_AS_FRONTEND_MILESTONE`
- Closure date: 2026-05-11 KST
- Scope: `NV_NVDLA_partition_m` frontend flow only
- Final frontend candidate: `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b`
- Closure declaration: `00_Project_Tracking/PROJECT_CLOSURE.md`
- Repository README updated on 2026-05-12 KST to summarize the closed frontend milestone, flow layout, major results, common commands, tracking discipline, and signoff boundary.
- Meaning: synthesis/R2N/DFT/scan STA setup/N2N/ATPG frontend milestone complete.
- Claim boundary: not backend physical signoff, not signoff-clean, not tapeout-ready.

## Current Best Results

| Stage | Run | Result | Evidence | Blocking Items |
| --- | --- | --- | --- | --- |
| Frontend milestone closure | `PROJECT_CLOSURE.md` | `RECORDED` | Status `CLOSED_AS_FRONTEND_MILESTONE`; VP8b frontend flow declared closed for `NV_NVDLA_partition_m` | Backend physical signoff and signoff-clean claims remain out of scope |
| Synthesis | `partition_m_4p0ns` | `PASS_WITH_NOTE` | WNS `+0.0117 ns`, TNS `0`, violating paths `0` | Max transition/cap violations deferred to backend |
| STA setup | `partition_m_4p0ns` | `PASS_WITH_NOTE` | PT setup WNS `+0.0304 ns`, TNS `0` | Hold/removal deferred to backend |
| DFT initial | `partition_m_4p0ns_dft` | `FAIL` | D9 `67135`, S19 `67135`, scan chains too small | Clock-gating prevented shift clock activation |
| DFT synthesis | `partition_m_4p0ns_dftcg` | `PASS_WITH_NOTE` | WNS `+0.0031 ns`, TNS `0`, violating paths `0` | DFT-only clock-gating bypass build |
| DFT pre-check | `partition_m_4p0ns_dftcg_probe` | `PASS_WITH_NOTE` | D9 `0`, sequential violations `0`, 32 chains x about 2100 cells | TEST-332, D8, D10 remain |
| Full DFT | `partition_m_4p0ns_dftcg_dft` | `PASS_WITH_NOTE` | Post-DFT DRC total `2`, S19 `0`, 32 chains x `2099-2100`, WNS `+0.0031 ns` | C4/C26 reset protocol violations remain |
| DFT reset-protocol pre-check | `partition_m_4p0ns_dftcg_const_reset_probe` | `PASS_WITH_NOTE` | `dla_reset_rstn` modeled as `Constant 1`, D8/D10 `0`, sequential violations `0` | Pre-DFT TEST-332 remains |
| Full DFT reset protocol | `partition_m_4p0ns_dftcg_const_reset_dft` | `PASS_WITH_NOTE` | Post-DFT DRC total `0`, 32 chains x `2099-2100`, WNS `0.0000 ns`, TNS `0` | Max transition/cap cleanup remains |
| DFT synthesis with GHM | `partition_m_4p0ns_dftcg_ghm` | `PASS_WITH_NOTE` | DC topo completed, SVF `2.7M`, setup/hold WNS `0.0000 ns`, TNS `0` | Max transition/cap and high-fanout cleanup deferred to backend |
| Scan-netlist STA | `partition_m_4p0ns_dftcg_const_reset_scan_sta` | `PASS_WITH_NOTE` | Setup WNS `+0.0360 ns`, TNS `0`, setup violations `0` | Async hold/removal and max transition/cap deferred to backend |
| Formality R2N | `partition_m_4p0ns_dftcg_r2n` | `FAIL` | R2N verify failed: 1587 passing, 282276 failing, 67046 unverified | Reference black-box/unmatched points and missing `guide_hier_map`; R2N setup needs improvement |
| Formality R2N GHM | `partition_m_4p0ns_dftcg_ghm_r2n` | `FAIL` | `hier_map` guidance accepted `32`, but 2154 reference black-boxes and 282276 failing compare points remain | DW sim-file/reference modeling still wrong |
| Formality R2N NVDW | `partition_m_4p0ns_dftcg_ghm_r2n_nvdw` | `FAIL` | Reference black-boxes reduced to `2`, unmatched compare points reduced to `32`, failing compare points reduced to `20` | Remaining mismatch is CMAC DW carry-save tree modeling |
| Formality R2N DWROOT | `partition_m_4p0ns_dftcg_ghm_r2n_dwroot` | `DEFERRED` | DWROOT elaborated `DW02_tree_*_verif_en1` but stayed in verification model build and was terminated | `FM-424` on DW02_multp fanout; too expensive for current run |
| Formality R2N default fallback | `partition_m_4p0ns_dftcg_ghm_r2n_nvdw_synth` | `FAIL` | `hier_map` accepted `32`; 2 black-boxes, 32 unmatched, 20 failing, 67039 unverified due failing-point limit | Current fast debug baseline; not signoff |
| Formality R2N failing-point limit debug | `partition_m_4p0ns_dftcg_ghm_r2n_nvdw_limit200` | `FAIL` | Limit raised to `200`; 5218 passing, 200 failing, 63235 unverified; first 200 failures all under `u_NV_NVDLA_cmac/u_core/u_mac_5` | Confirms the issue is a MAC5 partial-product/carry-save mismatch cluster, not only the default 20-point cap |
| Formality R2N MAC5 dont-verify debug | `partition_m_4p0ns_dftcg_ghm_r2n_nvdw_mac5_pp_dv` | `FAIL` | MAC5 `pp_out_l0n*` excluded as 1152 dont-verify DFFs; first 200 failures moved to `u_mac_4` | Mismatch repeats across CMAC MAC array; dont-verify is debug-only, not a waiver |
| Formality R2N analyze_points debug | `partition_m_4p0ns_dftcg_ghm_r2n_nvdw_analyze20` | `FAIL` | `analyze_points` found 11 unmatched cone inputs, 1 rejected guidance command, and 94 required inputs | Rejected `reg_constant` guidance is now the strongest Formality-reported root-cause clue |
| Formality R2N SVF rejected detail | `partition_m_4p0ns_dftcg_ghm_r2n_nvdw_svfdetail` | `FAIL` | `reg_constant` rejected `32`; `multiplier` rejected `174`; failing compare points `20` | Confirms rejected guidance is in CMAC MAC `pp_out_l2n*` constants and `DW02_tree` multiplier/carry-save cells |
| DFT synthesis with CMAC verification priority | `partition_m_4p0ns_dftcg_ghm_vp2` | `PASS_WITH_NOTE` | DC topo completed; `hdlin_verification_priority=1`; CMAC `NV_NVDLA_CMAC_CORE_mac` and `NV_NVDLA_CMAC_CORE_MAC_mul` marked high priority; WNS `0.0000`, TNS `0` | Max transition/cap cleanup deferred to backend |
| Formality R2N CMAC verification-priority build | `partition_m_4p0ns_dftcg_ghm_vp2_r2n_nvdw` | `FAIL` | Unmatched compare points improved to `0`; rejected `reg_constant` improved to `0`; R2N still fails with 20 failing DFFs under `u_mac_3` | Rejected `multiplier` guidance increased to `270`; `DW02_tree`/carry-save guidance still unresolved |
| DFT synthesis with NVDLA DW fallback alignment | `partition_m_4p0ns_dftcg_ghm_vp3_nvdw` | `FAIL` | DC topo completed and produced DDC/netlist/SVF using `DESIGNWARE_NOEXIST`/`NV_DW02_tree`; CMAC verification priority applied | Setup WNS `-0.2117 ns`, so this is debug-only and not a 4.0 ns synthesis signoff build |
| Formality R2N NVDLA DW fallback-aligned build | `partition_m_4p0ns_dftcg_ghm_vp3_nvdw_r2n` | `PASS` | Verification `SUCCEEDED`; 68301 passing, 0 failing/aborted/unverified; total SVF guidance accepted `10872`, rejected `0` | R2N pass is tied to a timing-failing debug synthesis build |
| Fallback-DW timing sweep | `partition_m_4p0ns_dftcg_ghm_vp4/vp5/vp6_nvdw` | `FAIL` | VP5 was closest at WNS `-0.0264 ns`, TNS `-5.7297`, violating paths `538`; VP4 and VP6 also failed setup | Sweep data only; no setup waiver |
| Fallback-DW timing-clean build | `partition_m_4p0ns_dftcg_ghm_vp7_nvdw_oc3p6_inc4p0` | `PASS_WITH_NOTE` | Final clock `4.0 ns`; setup slack `+0.0016 ns`, TNS `0`, violating paths `0`; hold clean | R2N failed on 1 compare point caused by `SDFFSSRX1_RVT` mapping |
| Formality R2N VP7 timing-clean build | `partition_m_4p0ns_dftcg_ghm_vp7_nvdw_oc3p6_inc4p0_r2n` | `FAIL` | SVF guidance accepted `10923`, rejected `0`; 68300 passing, 1 failing compare point | Failing point `u_mac_1/mac_out_data_reg_85_`; implementation-only cone input from set/reset scan flop |
| Fallback-DW guarded timing-clean build | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b` | `PASS_WITH_NOTE` | Final clock `4.0 ns`; setup slack `+0.0008 ns`, TNS `0`, violating paths `0`; hold clean; `SDFFSSRX` absent from netlist search | Max transition `1336`, max cap `2021`, and constraint-model warnings remain |
| Formality R2N guarded timing-clean build | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_r2n` | `PASS` | Verification `SUCCEEDED`; 68301 passing, 0 failing/aborted/unverified; total SVF guidance accepted `10885`, rejected `0` | 2 reference black-box placeholders remain; full signoff-clean still blocked by synthesis DRC/constraint warnings |
| VP8b full DFT reset protocol | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_dft` | `PASS_WITH_NOTE` | Post-DFT DRC total `0`; 32 chains x `2088-2089`; post-DFT setup slack `+0.0008 ns`, TNS `0` | Max transition/cap cleanup remains; clock-gate pattern match was 0 but DRC passed |
| VP8b scan-netlist STA | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_scan_sta` | `PASS_WITH_NOTE` | PT setup clean; `nvdla_core_clk` setup WNS `+0.0128 ns`, TNS `0`, setup violations `0` | Async removal WNS `-0.0315 ns`, TNS `-71.0320`, 2383 paths; max transition/cap deferred |
| VP8b Formality N2N | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_n2n` | `PASS_WITH_NOTE` | Verification `SUCCEEDED`; 68301 passing, 0 failing/aborted/unverified | 64 implementation-only scan points/ports are expected unmatched objects |
| VP8b TetraMAX ATPG | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_atpg` | `PASS_WITH_NOTE` | ATPG DRC clean; stuck-at coverage `99.81%`; 20317 basic-scan patterns | Coverage lower and pattern count higher than previous const-reset ATPG; ND `16458` faults remain |
| Frontend final report | `FRONTEND_FINAL_REPORT.md` | `RECORDED` | Captures VP8b frontend closure: synthesis, R2N, DFT, scan STA, N2N, ATPG | Not backend signoff-clean; generated reports tracked by explicit request; long logs excluded |
| Repository README | `README.md` | `PASS_WITH_NOTE` | README updated on 2026-05-12 with current status, layout, final VP8b result table, common commands, and tracking rules; pushed in commit `d68c6be` | Documentation-only update; no EDA tool rerun; technical caveats unchanged |
| Local planning file ignore cleanup | `.gitignore` | `PASS_WITH_NOTE` | `AGENTS.md`, `nvdla_frontend_implementation_plan.md`, `progress.md`, `task_plan.md`, and `findings.md` are ignored and removed from git tracking while retained locally | Repository tracking-only update; no EDA tool rerun; technical caveats unchanged |
| Git report tracking | `7594062` | `PASS_WITH_NOTE` | Pushed frontend final report and `415` generated `4_report` files to `origin/master`; generated `3_log` tracking contains only `.gitkeep` placeholders | GitHub warned two Formality match reports are `55.82 MB`, above the recommended `50 MB`; push succeeded |
| Project memory refresh | `/DATA/home/edu135/.codex/memories/nvdla-front-end-flow.md` | `RECORDED` | 2026-05-11 context scan reviewed docs, scripts, git state, and representative VP8b reports; no EDA rerun | Status unchanged; remaining open items and non-signoff-clean caveats still apply |
| Formality N2N | `partition_m_4p0ns_dftcg_const_reset_n2n` | `PASS_WITH_NOTE` | Verification `SUCCEEDED`, 68653 passing, 0 failing | Scan-only implementation ports are expected unmatched ports |
| TetraMAX ATPG | `partition_m_4p0ns_dftcg_const_reset_atpg` | `PASS_WITH_NOTE` | DRC clean, stuck-at coverage `99.91%`, 14836 patterns | ND faults and reset assertion coverage remain outside current milestone |

## Key Decisions

- Timing target for the current frontend flow is `4.0 ns`.
- `3.5 ns` is not the active target because it creates setup violation.
- Hold/removal cleanup is deferred to backend.
- Functional netlist remains `partition_m_4p0ns`.
- DFT scan insertion should use the DFT-specific `VLIB_BYPASS_POWER_CG` synthesis input until a production clock-gate test-enable strategy is implemented.
- During scan, `dla_reset_rstn` is held inactive as `Constant 1` because it also feeds the reset synchronizer data path; reset assertion testing is not claimed by this scan protocol.
- Max transition/capacitance violations are backend-deferred and must be handled during physical implementation.
- Post-DFT functional equivalence for this milestone is covered by N2N, not R2N.
- R2N GHM generation is now fixed, and DW reference black-boxing was reduced from 2154 black-boxes to 2 using an NVDLA DW fallback setup. Raising the failing-point limit from 20 to 200 showed the failures clustered under CMAC MAC partial-product/carry-save compare points. `analyze_points` and SVF rejected-guidance reports identified rejected `reg_constant` and `multiplier` guidance. Re-synthesis with CMAC verification priority fixed the `reg_constant` rejects and removed unmatched compare points, but VP2 still failed because DC synthesized with Synopsys `DW02_tree` while Formality reference used NVDLA fallback `NV_DW02_tree`. VP3 aligned DC to the same `DESIGNWARE_NOEXIST`/NVDLA fallback model and R2N passed with all SVF guidance accepted, but failed 4.0 ns setup. VP8b is now the best R2N-capable timing candidate: it uses NVDLA DW fallback, compiles at 3.6 ns, restores/report-writes at 4.0 ns, runs final incremental compile, and marks `SDFFSSRX*_RVT` as `dont_use`; DC setup/hold are clean at 4.0 ns and R2N passes. Direct DWROOT setup remains available as opt-in but was deferred after a long verification-model build.
- VP8b downstream DFT flow has been rerun end-to-end: DFT insertion DRC passes, scan-netlist STA setup passes, N2N passes, and ATPG DRC/coverage completes. The remaining items are backend-deferred hold/removal and max transition/cap cleanup, plus ATPG coverage/fault classification if higher coverage is required.
- Generated reports are tracked in git by explicit user request on 2026-05-08. Long generated logs and generated implementation outputs remain ignored unless separately requested. The report-only tracking commit `7594062` was pushed to `origin/master`; generated log tracking currently contains only `.gitkeep` placeholders.

## Not Signoff-Clean Yet

- Do not claim signoff-clean while max transition/cap violations remain.
- Do not claim full flow signoff-clean until the VP8b synthesis DRC and constraint-model warnings are either fixed or explicitly waived/deferred with backend owner agreement.
- The DFT clock-gating bypass run is valid as a front-end scan enablement path, but it is not a replacement for the functional low-power clock-gated implementation.
