# Current Execution Plan

## Milestone 1: Partition M DC Elaborate Smoke Test

Goal: prove that `NV_NVDLA_partition_m` can be analyzed, elaborated, and linked in Design Compiler using local SAED32 libraries and the cloned NVDLA RTL.

Acceptance criteria:

- `dc_shell` analyze completes for `2_synthesis/1_input/filelists/NV_NVDLA_partition_m.f`.
- `elaborate NV_NVDLA_partition_m` completes.
- `link` completes with no unresolved references.
- `2_synthesis/2_output/partition_m/db/NV_NVDLA_partition_m.elab.ddc` is generated.
- `2_synthesis/4_report/partition_m/NV_NVDLA_partition_m.check_design.elab.rpt` is generated for review.

Result: pass on 2026-05-07.

Evidence:

- `2_synthesis/3_log/partition_m/NV_NVDLA_partition_m.elab.log`
- `2_synthesis/4_report/partition_m/NV_NVDLA_partition_m.check_design.elab.rpt`
- `2_synthesis/2_output/partition_m/db/NV_NVDLA_partition_m.elab.ddc`

Known follow-up:

- `check_design` reports `first_stage_of_sync` as an empty black-box-like marker. It has no unresolved link impact, but should be tracked before final portfolio reporting.
- Full DC synthesis should now be added as the next milestone.

## Milestone 2: Partition M Baseline DC Synthesis

Goal: convert the elaborate-only flow into a full synthesis flow.

Planned steps:

1. Add `2_synthesis/scripts/run_dc.tcl` using the proven library setup and filelist. Done.
2. Read `2_synthesis/1_input/constraints/NV_NVDLA_partition_m.sdc`. Done in script.
3. Run `compile_ultra -no_seq_output_inversion -no_autoungroup -scan`.
4. Generate `.ddc`, gate netlist, SDC, SVF, QoR, timing, area, power, constraint, and check reports.
5. Review timing and constraint reports before moving to PrimeTime.

Acceptance criteria:

- Gate netlist and DDC are generated.
- `check_design` and `check_timing` reports are generated.
- Major unresolved-link errors are absent.
- Any timing or lint issues are recorded in `findings.md`.
