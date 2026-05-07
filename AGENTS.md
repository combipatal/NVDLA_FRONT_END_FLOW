# Project Agent Instructions

## Run Log Discipline

When a tool run completes, update the project logs before finishing the task.

Always record completed runs in:

```text
00_Project_Tracking/RUN_LOG.md
00_Project_Tracking/RESULT_SUMMARY.md
00_Project_Tracking/PROJECT_STATUS.md
```

For each run, record:

- Date
- Command
- Stage
- Result
- Input artifacts
- Output artifacts
- Key reports
- Pass/fail evidence
- Warnings or violations
- Reason for any waiver/defer decision
- Next action

Use these result labels:

- `PASS`
- `PASS_WITH_NOTE`
- `FAIL`
- `INVALID`
- `DEFERRED`
- `RECORDED`

Do not leave important results only in chat, terminal output, or ignored tool logs.

If a run fails, record:

- Stage
- Command
- Log path
- First fatal error
- Suspected root cause
- Next action

If a warning is accepted, record:

- Warning ID or message
- Tool and report path
- Why it does not block the current milestone
- Whether it is waived, deferred, or needs later root-cause analysis

Generated tool outputs, logs, reports, and work directories stay ignored by git unless explicitly requested.

Track in git only:

- Scripts
- Constraints
- Filelists
- Wrappers
- Configs
- Project documentation
- Curated summary reports
- Decision records

Do not claim signoff-clean unless every remaining warning or violation is either fixed or explicitly categorized with evidence.
