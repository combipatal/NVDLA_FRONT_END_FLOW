# Frontend Final Report

- Date: 2026-05-08 KST
- Design: `NV_NVDLA_partition_m`
- Frontend closure candidate:
  - Pre-DFT synthesis/R2N: `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b`
  - Post-DFT scan insertion: `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_dft`
  - Scan-netlist STA: `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_scan_sta`
  - Formality N2N: `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_n2n`
  - TetraMAX ATPG: `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_atpg`

## Scope

This report closes the frontend milestone only. It does not claim backend physical signoff or signoff-clean timing/DRC.

Frontend scope includes:

- Topographical synthesis at the active `4.0 ns` target.
- RTL-to-netlist Formality R2N on the selected pre-DFT synthesis candidate.
- DFT scan insertion with reset held inactive for scan.
- Scan-netlist STA setup check.
- Pre-DFT to post-DFT Formality N2N.
- TetraMAX stuck-at ATPG.

## Final Results

| Stage | Run | Result | Evidence |
| --- | --- | --- | --- |
| Synthesis | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b` | `PASS_WITH_NOTE` | DC setup slack `+0.0008 ns`, TNS `0`, violating paths `0`; hold clean |
| Formality R2N | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_r2n` | `PASS` | `Verification SUCCEEDED`; `68301` passing; `0` failing/aborted/unverified; SVF guidance `10885` accepted, `0` rejected |
| DFT insertion | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_dft` | `PASS_WITH_NOTE` | Post-DFT DRC total `0`; 32 scan chains; chain lengths `2088-2089` |
| Scan-netlist STA | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_scan_sta` | `PASS_WITH_NOTE` | PT setup clean; `nvdla_core_clk` setup WNS `+0.0128 ns`, TNS `0`, setup violations `0` |
| Formality N2N | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_n2n` | `PASS_WITH_NOTE` | `Verification SUCCEEDED`; `68301` passing; `0` failing/aborted/unverified |
| TetraMAX ATPG | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_atpg` | `PASS_WITH_NOTE` | ATPG DRC clean; stuck-at test coverage `99.81%`; `20317` basic-scan patterns |

## Key Fixes

- Enabled DC/Formality reference-model alignment for CMAC DesignWare fallback modeling using the NVDLA DW fallback path.
- Added separate compile and final report/writeout clock controls:
  - `DC_COMPILE_CLK_PERIOD`
  - `DC_CLK_PERIOD`
- Added final incremental compile control:
  - `DC_FINAL_INCREMENTAL_COMPILE=1`
- Added an optional guard against the FM-risky set/reset scan flop mapping that caused the VP7 one-point R2N failure:
  - `DC_DONT_USE_FM_RISKY_SCAN_FLOPS=1`
  - Targets `SDFFSSRX*_RVT`
- Kept `dla_reset_rstn` inactive as a scan constant because it also feeds reset synchronizer data.

## Non-Blocking Notes

The following are recorded and not claimed clean in this frontend milestone:

- Max transition/capacitance violations remain in synthesis, DFT, and PT reports.
- Scan-netlist STA has async removal violations:
  - WNS `-0.0315 ns`
  - TNS `-71.0320 ns`
  - Violating paths `2383`
- PT `check_timing` still reports ports with no clock-relative input delay.
- TetraMAX coverage is `99.81%`, lower than the earlier const-reset ATPG run at `99.91%`.
- TetraMAX has `16458` not-detected faults and `11` ATPG-untestable faults.
- Reset assertion coverage is not claimed by the current scan protocol.

## Git Tracking

Generated scripts and reports are tracked in git for this project per explicit user request on 2026-05-08.

Generated logs are not tracked because the tool logs are very long and noisy. Generated implementation outputs such as DDC, netlist, SDF, SPF, STIL, and fault databases remain generated artifacts unless separately requested.

## Frontend Closure Statement

The selected VP8b frontend flow is complete for the project scope:

```text
Synthesis timing clean
-> Formality R2N PASS
-> DFT insertion DRC PASS
-> scan-netlist STA setup clean
-> Formality N2N PASS
-> TetraMAX ATPG PASS_WITH_NOTE
```

This is a frontend completion result, not a backend physical signoff result.
