# NVDLA Front-End Flow

Partition-level Synopsys front-end implementation flow for selected NVIDIA NVDLA compute partitions.

Main scope:
- `NV_NVDLA_partition_m` synthesis, STA, Formality, and clock period sweep
- Optional reuse on `NV_NVDLA_partition_a`
- Optional block-level DFT/ATPG feasibility and `partition_m` + `partition_a` integration STA

Flow directory convention:

```text
1_vcs/
2_synthesis/
3_sta/
4_dft/
5_formality/
6_sweep/
```

Each flow stage uses the same internal layout:

```text
1_input/
2_output/
3_log/
4_report/
scripts/
```
