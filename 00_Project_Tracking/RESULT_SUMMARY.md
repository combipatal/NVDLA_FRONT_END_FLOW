# Result Summary

## Current Best Results

| Stage | Run | Result | Evidence | Blocking Items |
| --- | --- | --- | --- | --- |
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
- R2N GHM generation is now fixed, and DW reference black-boxing was reduced from 2154 black-boxes to 2 using an NVDLA DW fallback setup. R2N still fails on 20 CMAC DW carry-save tree compare points. Direct DWROOT setup is available as opt-in but was deferred after a long verification-model build.

## Not Signoff-Clean Yet

- Do not claim signoff-clean while max transition/cap violations remain.
- Do not claim full flow signoff-clean until R2N is either fixed or formally replaced by an approved equivalence signoff strategy.
- The DFT clock-gating bypass run is valid as a front-end scan enablement path, but it is not a replacement for the functional low-power clock-gated implementation.
