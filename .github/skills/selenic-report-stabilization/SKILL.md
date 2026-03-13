---
name: selenic-report-stabilization
description: 'Review Selenic report.json and produce prioritized actionable stabilization tasks for Selenium Maven tests. Use when users say: review report.json, analyze selenic report, create actionable tasks from self healing, stabilize flaky selenium tests, or return findings in a markdown table with suggestion old behavior new impact level.'
argument-hint: '[optional] path to report json, default: report/report.json'
user-invocable: true
---

# Selenic Report Stabilization

## What This Skill Produces
- Reads a Selenic analyzer JSON report (`report.json`).
- Identifies flaky or fragile automation behavior that was healed or partially healed.
- Produces prioritized, actionable tasks to stabilize tests and reduce self-healing dependence.
- Returns results in markdown table format:
- `suggestion`
- `old behavior`
- `new`
- `impact level`

## When To Use
- A Selenic run completed and generated `report/report.json` or `report2.json`.
- You want to convert healing telemetry into engineering backlog items.
- You need a concise, stakeholder-ready output table.

## Inputs
- Primary input file:
- `report/report.json` (default)
- Optional alternatives:
- `report/report2.json`
- custom path provided by user
- Optional codebase context for mapping findings to implementation files:
- `src/test/java/**`

## Procedure
1. Locate report file.
2. Validate JSON and confirm scenario/test entries are present.
3. Extract instability signals:
- `metadata.passed == false`
- `injectedIgnore == true`
- `recommendedWaitTime > originalWaitTime`
- repeated locator attempts for same command
4. Group findings by root cause category:
- brittle locator strategy
- synchronization/wait gaps
- ambiguous element targeting
- positional/index-based selectors
5. Map each finding to code references in page objects/tests (if available).
6. Convert each finding into a task with:
- suggested change
- old behavior (current state + evidence)
- new behavior (target state)
- impact level (`High`, `Medium`, `Low`)
7. Return a markdown table prioritized by impact and effort:
- sort by impact (High to Low)
- within each impact level, place lower-effort fixes first

## Decision Points
- Report missing or unreadable:
Stop and request valid report path.
- Report has no healing/failure indicators:
Return “No stabilization findings” and include residual risk note.
- Healing exists but code mapping cannot be found:
Return task with report evidence only and mark “code mapping pending”.
- Multiple similar findings:
Merge into one task to avoid duplicate backlog items.

## Quality Criteria
- Every task references concrete evidence (report field and/or code location).
- Every task is actionable by a test engineer without additional interpretation.
- Impact level is justified by execution risk and flakiness likelihood.
- Prioritization also considers implementation effort (prefer high-value, low-effort tasks first).
- Output uses the requested table schema exactly.

## Output Template
| suggestion | old behavior | new | impact level |
|---|---|---|---|
| Replace brittle locator in `HomePage` | Absolute XPath fails then heals in report | Use stable id/data-testid locator | High |

## Completion Checks
- At least one task is produced when report contains healing/failure signals.
- Table columns match requested format exactly.
- Findings are ordered by impact severity.
- No unverifiable claims are included.

## Related Workflow
- Run tests with Selenic first using skill:
- `mvn-selenic-self-healing`
- Then apply this skill to convert report output into stabilization backlog items.
