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

## Key Decisions

- Timing target for the current frontend flow is `4.0 ns`.
- `3.5 ns` is not the active target because it creates setup violation.
- Hold/removal cleanup is deferred to backend.
- Functional netlist remains `partition_m_4p0ns`.
- DFT scan insertion should use the DFT-specific `VLIB_BYPASS_POWER_CG` synthesis input until a production clock-gate test-enable strategy is implemented.

## Not Signoff-Clean Yet

- Do not claim signoff-clean while max transition/cap violations remain.
- Do not claim DFT signoff-clean while post-DFT C4/C26 reset protocol violations remain uncategorized or unfixed.
- The DFT clock-gating bypass run is valid as a front-end scan enablement path, but it is not a replacement for the functional low-power clock-gated implementation.
