# Task Plan

Source plan:
- `/DATA/home/edu135/nvdla_frontend_implementation_plan.md`

Initial execution order:
1. Clone or attach NVDLA source under `rtl/nvdla`.
2. Inspect NVIDIA reference synthesis flow.
3. Build `partition_m` analyze/elaborate/link smoke test.
4. Add DC synthesis flow.
5. Add PrimeTime STA flow.
6. Add Formality RTL-to-netlist verification flow.
7. Add clock period sweep automation.
8. Reuse the same flow for `partition_a`.
9. Sanitize public artifacts before portfolio use.

Flow layout:
- `1_vcs/{1_input,2_output,3_log,4_report,scripts}`
- `2_synthesis/{1_input,2_output,3_log,4_report,scripts}`
- `3_sta/{1_input,2_output,3_log,4_report,scripts}`
- `4_dft/{1_input,2_output,3_log,4_report,scripts}`
- `5_formality/{1_input,2_output,3_log,4_report,scripts}`
- `6_sweep/{1_input,2_output,3_log,4_report,scripts}`
