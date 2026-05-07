# Findings

Record project findings here as issues are discovered.

Format:

```text
Issue:
Action:
Result:
Lesson:
Evidence:
```

```text
Issue:
partition_m initial DC link failed with unresolved NV_NVDLA_reset, NV_NVDLA_sync3d, NV_NVDLA_sync3d_s, DW02_tree, and DW_minmax references.

Action:
Added rtl/nvdla/vmod/nvdla/car to the partition filelists and added dw_foundation.sldb as the DC synthetic/link library.

Result:
partition_m analyze/elaborate/link smoke test passes and writes 2_synthesis/2_output/partition_m/db/NV_NVDLA_partition_m.elab.ddc in the numbered flow layout.

Lesson:
The NVDLA reference flow's copied source sandbox hides required common CAR modules, and the reference config relies on DesignWare libraries for arithmetic tree/minmax components.

Evidence:
2_synthesis/3_log/partition_m/NV_NVDLA_partition_m.elab.log
2_synthesis/4_report/partition_m/NV_NVDLA_partition_m.check_design.elab.rpt
```

```text
Issue:
check_design reports one Black box (LINT-55) for first_stage_of_sync.

Action:
Inspected the report after link success.

Result:
The marker has no cells or nets and does not prevent link or DDC generation. Track it for final report cleanup instead of treating it as a smoke-test blocker.

Lesson:
NVDLA sync wrappers can include structural marker modules that trigger lint warnings without being unresolved references.

Evidence:
2_synthesis/4_report/partition_m/NV_NVDLA_partition_m.check_design.elab.rpt
```
