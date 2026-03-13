#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_FILE="$SKILL_DIR/assets/run-selenic-tests.template.sh"

PROJECT_DIR="$PWD"
DRY_RUN=false

usage() {
  cat <<'USAGE'
Usage: generate-selenic-runner.sh [options]

Generate run-selenic-tests.sh in a target Maven project.

Options:
  --project-dir <path>      Maven project root (default: current dir)
  --dry-run                 Validate without writing files
  -h, --help                Show help
USAGE
}

log() {
  printf '[configure-selenic] %s\n' "$*"
}

fail() {
  printf '[configure-selenic] ERROR: %s\n' "$*" >&2
  exit 1
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --project-dir)
        [[ $# -ge 2 ]] || fail "Missing value for --project-dir"
        PROJECT_DIR="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        fail "Unknown argument: $1"
        ;;
    esac
  done
}

main() {
  parse_args "$@"

  PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
  local pom_file="$PROJECT_DIR/pom.xml"
  local runner_file="$PROJECT_DIR/run-selenic-tests.sh"
  local license_file="$PROJECT_DIR/license.env"
  local license_template="$PROJECT_DIR/license.env.template"

  [[ -f "$TEMPLATE_FILE" ]] || fail "Template not found: $TEMPLATE_FILE"
  [[ -f "$pom_file" ]] || fail "pom.xml not found in target project: $PROJECT_DIR"

  log "Target project: $PROJECT_DIR"
  log "Template: $TEMPLATE_FILE"

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[DRY-RUN] Would write: $runner_file"
    if [[ ! -f "$license_file" ]]; then
      log "[DRY-RUN] Would create: $license_template"
    fi
    log "Validation successful."
    exit 0
  fi

  cp "$TEMPLATE_FILE" "$runner_file"
  chmod +x "$runner_file"
  log "Generated runner: $runner_file"

  if [[ ! -f "$license_file" ]]; then
    cat > "$license_template" << 'LICENSE_TEMPLATE'
# Copy this file to license.env and fill values.
lss.url=
lss.user=
lss.pass=
LICENSE_TEMPLATE
    log "Created license template: $license_template"
  else
    log "license.env already exists; template not created."
  fi

  log "Done. Next: bash $runner_file --dry-run"
}

main "$@"
