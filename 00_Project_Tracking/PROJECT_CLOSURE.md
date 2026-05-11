# NVDLA Frontend Milestone Closure

## Date

- Closure date: 2026-05-11 KST
- Status: `CLOSED_AS_FRONTEND_MILESTONE`
- Scope: `NV_NVDLA_partition_m` frontend flow only

## Closure Declaration

The NVDLA `NV_NVDLA_partition_m` frontend milestone is closed as `CLOSED_AS_FRONTEND_MILESTONE`.

This closure covers the selected VP8b frontend flow through synthesis, RTL-to-netlist Formality R2N, DFT scan insertion, scan-netlist STA setup review, pre-DFT to post-DFT Formality N2N, and TetraMAX stuck-at ATPG.

This is not a backend physical implementation closure and not a signoff-clean declaration.

## Final Frontend Candidate

| Stage | Final run |
| --- | --- |
| Pre-DFT synthesis/R2N | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b` |
| Post-DFT scan insertion | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_dft` |
| Scan-netlist STA | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_scan_sta` |
| Formality N2N | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_n2n` |
| TetraMAX ATPG | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_atpg` |

## Final Evidence

| Stage | Result | Evidence |
| --- | --- | --- |
| Synthesis | `PASS_WITH_NOTE` | DC setup slack `+0.0008 ns`, TNS `0`, violating paths `0`; hold clean at the `4.0 ns` final clock |
| Formality R2N | `PASS` | `Verification SUCCEEDED`; `68301` passing compare points; `0` failing, aborted, and unverified compare points; SVF guidance `10885` accepted / `0` rejected |
| DFT insertion | `PASS_WITH_NOTE` | Post-DFT DRC total `0`; 32 scan chains; chain lengths `2088-2089` |
| Scan-netlist STA | `PASS_WITH_NOTE` | Setup clean; `nvdla_core_clk` setup WNS `+0.0128 ns`; TNS `0`; setup violations `0` |
| Formality N2N | `PASS_WITH_NOTE` | `Verification SUCCEEDED`; `68301` passing compare points; `0` failing, aborted, and unverified compare points |
| TetraMAX ATPG | `PASS_WITH_NOTE` | ATPG DRC clean; stuck-at coverage `99.81%`; `20317` basic-scan patterns; `16458` not-detected faults; `11` ATPG-untestable faults |

## Key Fixes

- Enabled DC/Formality reference-model alignment around CMAC DesignWare fallback modeling using the NVDLA DW fallback path.
- Emitted `guide_hier_map` guidance through `hdlin_enable_hier_map` and `set_verification_top`.
- Added separate compile and final report/writeout clock controls:
  - `DC_COMPILE_CLK_PERIOD`
  - `DC_CLK_PERIOD`
- Added final incremental compile control:
  - `DC_FINAL_INCREMENTAL_COMPILE=1`
- Added Formality-risk guard for set/reset scan flop mapping:
  - `DC_DONT_USE_FM_RISKY_SCAN_FLOPS=1`
  - Targets `SDFFSSRX*_RVT`
- Kept `dla_reset_rstn` inactive as a scan constant because the reset port also feeds reset synchronizer data.

## What This Milestone Proves

- `NV_NVDLA_partition_m` can be synthesized at the active frontend `4.0 ns` target with setup timing clean in DC.
- RTL-to-netlist Formality R2N passes for the selected pre-DFT candidate.
- DFT scan insertion completes with post-DFT DRC total violations `0`.
- Scan-netlist STA setup is clean for the selected post-DFT netlist.
- Pre-DFT to post-DFT Formality N2N passes in functional mode.
- TetraMAX stuck-at ATPG runs to completion with ATPG DRC clean and recorded coverage/fault evidence.

## Non-Blocking Notes

The following items are recorded and do not block this frontend milestone closure:

- Max transition/capacitance violations remain in synthesis, DFT, and PT reports.
- Scan-netlist STA async removal violations remain:
  - WNS `-0.0315 ns`
  - TNS `-71.0320 ns`
  - Violating paths `2383`
- PT `check_timing` reports ports with no clock-relative input delay.
- ATPG has `16458` not-detected faults and `11` ATPG-untestable faults.
- Reset assertion coverage is not claimed.
- The VP8b ATPG coverage `99.81%` is lower than the earlier const-reset ATPG run at `99.91%`.

## Claim Boundary

This closure is limited to the `NV_NVDLA_partition_m` frontend milestone. It does not include backend physical implementation, route, GDS, foundry signoff, or tapeout readiness.

## Do-Not-Claim List

Do not claim:

- Full project closure beyond this frontend milestone.
- Backend physical signoff closure.
- Signoff-clean timing or signoff-clean DRC.
- Tapeout-ready status.
- Foundry signoff clean status.
- Route/GDS completion.
- IR/EM closure.
- LVS closure.
- Antenna closure.
- Metal-fill closure.
- Reset assertion coverage.
- ATPG fault closure beyond the recorded `PASS_WITH_NOTE` evidence.

## Portfolio/Interview Safe Claim

Safe wording:

`Closed the NV_NVDLA_partition_m frontend milestone: synthesis timing clean at the 4.0 ns frontend target, Formality R2N PASS, DFT insertion DRC PASS, scan-netlist STA setup clean, Formality N2N PASS, and TetraMAX ATPG PASS_WITH_NOTE. Backend physical signoff and tapeout readiness were explicitly out of scope.`

## Optional Next Phase

- Clean up SDC/check_timing issues, including input delays without `-clock` and unconstrained endpoints.
- Hand off max transition/capacitance and async removal cleanup to backend physical implementation.
- Decide whether VP8b ATPG coverage delta requires additional ATPG effort or fault classification.
- Define a reset assertion test strategy if `dla_reset_rstn` assertion coverage is required.
- Reuse the flow on additional NVDLA partitions after `partition_m` remains stable.
