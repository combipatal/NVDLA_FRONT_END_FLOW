# NVDLA Front-End Flow

Partition-level Synopsys front-end implementation flow for selected NVIDIA NVDLA compute partitions.

Main scope:
- `NV_NVDLA_partition_m` synthesis, STA, Formality, and clock period sweep
- Optional reuse on `NV_NVDLA_partition_a`
- Optional block-level DFT/ATPG feasibility and `partition_m` + `partition_a` integration STA

