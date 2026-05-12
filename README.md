# NVDLA Front-End Flow

Partition-level Synopsys front-end implementation flow for selected NVIDIA NVDLA compute partitions.

This repository contains the RTL snapshot, constraints, filelists, wrappers, scripts, curated reports, and project tracking documents used to close the `NV_NVDLA_partition_m` front-end milestone.

## Current Status

- Status: `CLOSED_AS_FRONTEND_MILESTONE`
- Closure date: 2026-05-11 KST
- Active design: `NV_NVDLA_partition_m`
- Final frontend candidate: `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b`
- Target clock: `4.0 ns`
- Completed scope: synthesis, RTL-to-netlist Formality, DFT insertion, scan-netlist STA setup, netlist-to-netlist Formality, and TetraMAX ATPG
- Boundary: this is not backend physical signoff, not signoff-clean, and not tapeout-ready

The detailed closure record is maintained in:

- `00_Project_Tracking/PROJECT_CLOSURE.md`
- `00_Project_Tracking/FRONTEND_FINAL_REPORT.md`
- `00_Project_Tracking/PROJECT_STATUS.md`
- `00_Project_Tracking/RESULT_SUMMARY.md`
- `00_Project_Tracking/RUN_LOG.md`

## Repository Layout

```text
.
|-- 00_Project_Tracking/     Curated run logs, summaries, status, and closure docs
|-- 1_vcs/                   RTL simulation stage placeholder
|-- 2_synthesis/             Design Compiler synthesis inputs, scripts, outputs, reports
|-- 3_sta/                   PrimeTime STA scripts, outputs, reports
|-- 4_dft/                   DFT Compiler and TetraMAX ATPG scripts, outputs, reports
|-- 5_formality/             Formality R2N/N2N scripts, outputs, reports
|-- 6_sweep/                 Clock-period and implementation sweep stage placeholder
|-- docs/                    Execution plan and partition analysis notes
|-- rtl/                     NVDLA RTL snapshot and local support models
`-- wrappers/                Flow wrapper area
```

Each numbered flow stage follows the same internal convention:

```text
1_input/     User-maintained inputs such as constraints and filelists
2_output/    Generated implementation outputs
3_log/       Tool logs
4_report/    Tool reports
scripts/     Stage scripts and wrappers
```

Generated implementation outputs and long logs are intentionally ignored by git unless explicitly requested. Scripts, constraints, filelists, wrappers, configs, project documentation, curated summaries, and selected reports are tracked.

## Main Results

| Stage | Run | Result | Evidence |
| --- | --- | --- | --- |
| Synthesis | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b` | `PASS_WITH_NOTE` | Setup slack `+0.0008 ns`, TNS `0`, violating paths `0`; hold clean |
| Formality R2N | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_r2n` | `PASS` | Verification succeeded; `68301` passing compare points, `0` failing/aborted/unverified |
| DFT insertion | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_dft` | `PASS_WITH_NOTE` | Post-DFT DRC total `0`; `32` scan chains; chain lengths `2088-2089` |
| Scan STA | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_scan_sta` | `PASS_WITH_NOTE` | Setup WNS `+0.0128 ns`, TNS `0`, setup violations `0` |
| Formality N2N | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_n2n` | `PASS_WITH_NOTE` | Verification succeeded; scan-only unmatched implementation points expected |
| ATPG | `partition_m_4p0ns_dftcg_ghm_vp8_nvdw_oc3p6_inc4p0_nosdffssrx_b_const_reset_atpg` | `PASS_WITH_NOTE` | ATPG DRC clean; stuck-at coverage `99.81%`; `20317` basic-scan patterns |

Remaining warnings are recorded in the project tracking files. The most important deferred items are backend max transition/capacitance cleanup, async hold/removal cleanup, constraint-model cleanup, reset-test strategy, and any extra ATPG fault classification needed beyond the current milestone.

## Environment

The flow expects a Synopsys tool environment with access to the SAED32 EDK. The common environment setup is sourced from:

```bash
source 2_synthesis/1_input/env.sh
```

The scripts call tools such as:

- `dc_shell`
- `pt_shell`
- `fm_shell`
- `tmax`

Tool installation paths and library roots are environment dependent and are not vendored in this repository.

## Common Commands

Run Design Compiler synthesis:

```bash
DC_CLK_PERIOD=4.0 ./2_synthesis/scripts/run_one_dc.sh NV_NVDLA_partition_m
```

Run PrimeTime STA from a synthesis run:

```bash
./3_sta/scripts/run_one_pt.sh NV_NVDLA_partition_m partition_m_4p0ns
```

Run DFT insertion:

```bash
./4_dft/scripts/run_one_dft.sh NV_NVDLA_partition_m partition_m_4p0ns_dftcg
```

Run Formality RTL-to-netlist equivalence:

```bash
FM_RUN_NAME=partition_m_4p0ns_dftcg_r2n \
  ./5_formality/scripts/run_one_fm.sh r2n NV_NVDLA_partition_m
```

Run Formality netlist-to-netlist equivalence:

```bash
FM_RUN_NAME=partition_m_4p0ns_dftcg_const_reset_n2n \
  ./5_formality/scripts/run_one_fm.sh n2n NV_NVDLA_partition_m
```

Run TetraMAX ATPG:

```bash
./4_dft/scripts/run_one_tmax.sh NV_NVDLA_partition_m partition_m_4p0ns_dftcg_const_reset_dft
```

Many final milestone runs use explicit environment overrides for run names, input DDCs, SVFs, filelists, compile clock period, and Formality options. Use the matching entries in `00_Project_Tracking/RUN_LOG.md` and `00_Project_Tracking/RESULT_SUMMARY.md` when reproducing a specific run.

## Tracking Discipline

Per `AGENTS.md`, every completed tool run must be recorded in:

- `00_Project_Tracking/RUN_LOG.md`
- `00_Project_Tracking/RESULT_SUMMARY.md`
- `00_Project_Tracking/PROJECT_STATUS.md`

Do not leave important pass/fail evidence only in terminal output, chat, or ignored logs. If a warning is accepted, record the warning, report path, reason it does not block the current milestone, and whether it is waived, deferred, or needs later root-cause analysis.

## Notes

- The active milestone is for `NV_NVDLA_partition_m`; `NV_NVDLA_partition_a` is present as an optional reuse target but is not the closed final candidate.
- VP8b uses NVDLA DesignWare fallback alignment, compile overconstraint, final incremental compile, and an `SDFFSSRX*_RVT` dont-use guard to satisfy both timing and Formality R2N.
- During scan, `dla_reset_rstn` is held inactive as `Constant 1` because it also feeds reset synchronizer data paths. Reset assertion testing is not claimed by the current scan protocol.
- The project intentionally distinguishes front-end milestone closure from backend signoff.
