---
name: configure-project-for-selenic
description: 'Configure a Maven Selenium project for Parasoft Selenic. Generates a project-local run-selenic-tests.sh script, validates Maven structure, and bootstraps license template. Use when users say: configure project for selenic, set up selenic for selenium tests, generate run-selenic-tests.sh, or initialize self-healing runner.'
argument-hint: '[optional] project path, default current directory'
user-invocable: true
---

# Configure Project for Selenic

## What This Skill Produces
- Generates `<project>/run-selenic-tests.sh` from a packaged template.
- Validates Maven project prerequisites (`pom.xml`).
- Creates `<project>/license.env.template` when `license.env` is missing.
- Leaves project ready for Selenic self-healing execution.

## When To Use
- Project has Selenium tests but no Selenic runner script.
- Team needs a repeatable setup path for new Maven repositories.
- User asks to bootstrap Selenic setup and script generation.

## Procedure
1. Dry-run validation only:
`bash ./.github/skills/configure-project-for-selenic/scripts/generate-selenic-runner.sh --project-dir <maven-project-dir> --dry-run`
2. Generate runner script and optional license template:
`bash ./.github/skills/configure-project-for-selenic/scripts/generate-selenic-runner.sh --project-dir <maven-project-dir>`
3. Fill `<project>/license.env` with:
- `lss.url`
- `lss.user`
- `lss.pass`
4. Validate generated runner:
`bash <project>/run-selenic-tests.sh --dry-run`
5. Execute tests with Selenic:
`bash <project>/run-selenic-tests.sh`

## Decision Points
- Missing `pom.xml`:
Stop and report target is not a Maven project.
- Existing `run-selenic-tests.sh`:
Overwrite with latest template (safe regeneration).
- Missing `license.env`:
Create `license.env.template` and request credential input.

## Completion Checks
- `<project>/run-selenic-tests.sh` exists and is executable.
- `--dry-run` works without side effects.
- Maven command and analyzer command are printed.
- Project has valid `license.env` values before execution.

## Resources
- Generator script: [`generate-selenic-runner.sh`](./scripts/generate-selenic-runner.sh)
- Runner template: [`run-selenic-tests.template.sh`](./assets/run-selenic-tests.template.sh)
