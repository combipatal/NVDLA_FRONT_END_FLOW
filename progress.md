# Progress

## Current State

- Project folder created.
- Base workspace structure created.
- NVDLA RTL cloned into `rtl/nvdla` at revision `8e06b1b`.
- Reference `partition_m` and `partition_a` SDC files copied into `2_synthesis/1_input/constraints/`.
- Initial filelists, library setup, and DC elaborate smoke-test script added.
- `partition_m` DC analyze/elaborate/link smoke test passed.
- Fixed missing `vmod/nvdla/car` search path and DesignWare `dw_foundation.sldb` setup.
- Flow folders reorganized into numbered lab-style stages: `1_vcs`, `2_synthesis`, `3_sta`, `4_dft`, `5_formality`, `6_sweep`.

## Next Step

- Re-run `partition_m` DC analyze/elaborate/link smoke test in the new `2_synthesis` layout, then run full synthesis.
