#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LICENSE_FILE=""
SELENIC_IMAGE="parasoft/selenic:latest"
SELENIC_DIR="$PROJECT_DIR/.tools/selenic"
SELENIC_DATA_DIR="$PROJECT_DIR/selenic_data"
REPORT_DIR="$PROJECT_DIR/report"
PROPERTIES_FILE="$PROJECT_DIR/selenic.properties"

CLEAN_BUILD=false
HEADLESS=false
KEEP_SELENIC=false
IGNORE_TEST_FAILURES=false
DRY_RUN=false
BASE_URL=""

EXTRA_MAVEN_ARGS=()
TEMP_CONTAINER_ID=""

usage() {
  cat << 'USAGE'
Usage: run-selenic-tests.sh [options] [-- <extra maven args>]

Options:
  --license-env <path>      Path to license env file (default: ./license.env)
  --base-url <url>          Base URL passed to Maven properties
  --clean                   Run "mvn clean test" instead of "mvn test"
  --headless                Pass -Dheadless=true to Maven
  --keep-selenic            Reuse existing .tools/selenic if present
  --ignore-test-failures    Do not fail script when Maven tests fail
  --dry-run                 Print commands and exit
  -h, --help                Show help
USAGE
}

log() {
  printf '[selenic-runner] %s\n' "$*"
}

fail() {
  printf '[selenic-runner] ERROR: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [[ -n "$TEMP_CONTAINER_ID" ]]; then
    docker rm -v "$TEMP_CONTAINER_ID" >/dev/null 2>&1 || true
    TEMP_CONTAINER_ID=""
  fi
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --license-env)
        [[ $# -ge 2 ]] || fail "Missing value for --license-env"
        LICENSE_FILE="$2"
        shift 2
        ;;
      --base-url)
        [[ $# -ge 2 ]] || fail "Missing value for --base-url"
        BASE_URL="$2"
        shift 2
        ;;
      --clean)
        CLEAN_BUILD=true
        shift
        ;;
      --headless)
        HEADLESS=true
        shift
        ;;
      --keep-selenic)
        KEEP_SELENIC=true
        shift
        ;;
      --ignore-test-failures)
        IGNORE_TEST_FAILURES=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        while [[ $# -gt 0 ]]; do
          EXTRA_MAVEN_ARGS+=("$1")
          shift
        done
        break
        ;;
      *)
        fail "Unknown argument: $1"
        ;;
    esac
  done
}

read_env_value() {
  local key="$1"
  local value
  value="$(grep -E "^${key}=" "$LICENSE_FILE" | head -n1 | cut -d'=' -f2-)"
  printf '%s' "$value"
}

write_properties_file() {
  local target_file="$1"
  local lss_url="$2"
  local lss_user="$3"
  local lss_pass="$4"

  cat > "$target_file" << PROPS
parasoft.eula.accepted=true
selenic.license.use_network=true
license.network.use.specified.server=true
selenic.license.network.edition=automation_edition
license.network.url=${lss_url}
license.network.auth.enabled=true
license.network.user=${lss_user}
license.network.password=${lss_pass}
PROPS
}

prepare_selenic_binaries() {
  if [[ "$KEEP_SELENIC" == "true" && -d "$SELENIC_DIR" ]]; then
    log "Reusing existing Selenic directory: $SELENIC_DIR"
    return
  fi

  rm -rf "$SELENIC_DIR"
  mkdir -p "$(dirname "$SELENIC_DIR")"

  log "Creating temporary container from image $SELENIC_IMAGE"
  TEMP_CONTAINER_ID="$(docker create "$SELENIC_IMAGE")"

  log "Copying /opt/parasoft/selenic to $SELENIC_DIR"
  docker cp "$TEMP_CONTAINER_ID:/opt/parasoft/selenic" "$SELENIC_DIR"

  docker rm -v "$TEMP_CONTAINER_ID" >/dev/null 2>&1 || true
  TEMP_CONTAINER_ID=""
}

main() {
  parse_args "$@"
  trap cleanup EXIT

  [[ -n "$LICENSE_FILE" ]] || LICENSE_FILE="$PROJECT_DIR/license.env"
  LICENSE_FILE="$(cd "$(dirname "$LICENSE_FILE")" && pwd)/$(basename "$LICENSE_FILE")"

  require_cmd docker
  require_cmd mvn
  require_cmd java

  [[ -f "$PROJECT_DIR/pom.xml" ]] || fail "pom.xml not found in: $PROJECT_DIR"
  [[ -f "$LICENSE_FILE" ]] || fail "License file not found: $LICENSE_FILE"

  local lss_url
  local lss_user
  local lss_pass
  lss_url="$(read_env_value "lss.url")"
  lss_user="$(read_env_value "lss.user")"
  lss_pass="$(read_env_value "lss.pass")"

  [[ -n "$lss_url" ]] || fail "Missing lss.url in $LICENSE_FILE"
  [[ -n "$lss_user" ]] || fail "Missing lss.user in $LICENSE_FILE"
  [[ -n "$lss_pass" ]] || fail "Missing lss.pass in $LICENSE_FILE"

  local agent_jar="$SELENIC_DIR/selenic_agent.jar"
  local analyzer_jar="$SELENIC_DIR/selenic_analyzer.jar"

  if [[ "$DRY_RUN" != "true" ]]; then
    prepare_selenic_binaries
    write_properties_file "$PROPERTIES_FILE" "$lss_url" "$lss_user" "$lss_pass"
    write_properties_file "$SELENIC_DIR/selenic.properties" "$lss_url" "$lss_user" "$lss_pass"
    [[ -f "$agent_jar" ]] || fail "Selenic agent jar not found: $agent_jar"
    [[ -f "$analyzer_jar" ]] || fail "Selenic analyzer jar not found: $analyzer_jar"
  fi

  if [[ "$CLEAN_BUILD" == "true" ]]; then
    rm -rf "$SELENIC_DATA_DIR" "$REPORT_DIR"
  fi
  mkdir -p "$SELENIC_DATA_DIR" "$REPORT_DIR"

  local -a mvn_cmd
  if [[ "$CLEAN_BUILD" == "true" ]]; then
    mvn_cmd=(mvn clean test)
  else
    mvn_cmd=(mvn test)
  fi

  mvn_cmd+=("-Dmaven.test.failure.ignore=true")

  if [[ -n "$BASE_URL" ]]; then
    mvn_cmd+=("-DPARABANK_BASE_URL=$BASE_URL")
    mvn_cmd+=("-DBASE_URL=$BASE_URL")
    mvn_cmd+=("-Dbase.url=$BASE_URL")
  fi

  if [[ "$HEADLESS" == "true" ]]; then
    mvn_cmd+=("-Dheadless=true")
  fi

  mvn_cmd+=("-DargLine=-javaagent:${agent_jar}=captureDom=true,selfHealing=true,data=${SELENIC_DATA_DIR}")

  if [[ ${#EXTRA_MAVEN_ARGS[@]} -gt 0 ]]; then
    mvn_cmd+=("${EXTRA_MAVEN_ARGS[@]}")
  fi

  local -a analyzer_cmd
  analyzer_cmd=(java -jar "$analyzer_jar" -data "$SELENIC_DATA_DIR" -report "$REPORT_DIR")

  log "Project dir: $PROJECT_DIR"
  log "License file: $LICENSE_FILE"
  log "LSS url: $lss_url"
  log "LSS user: $lss_user"
  log "LSS password: ********"
  log "Maven command: ${mvn_cmd[*]}"
  log "Analyzer command: ${analyzer_cmd[*]}"

  if [[ "$DRY_RUN" == "true" ]]; then
    log "Dry-run mode enabled; exiting before execution."
    exit 0
  fi

  local final_status=0

  pushd "$PROJECT_DIR" >/dev/null

  set +e
  "${mvn_cmd[@]}"
  local mvn_status=$?
  set -e

  set +e
  "${analyzer_cmd[@]}"
  local analyzer_status=$?
  set -e

  popd >/dev/null

  if [[ $mvn_status -ne 0 ]]; then
    if [[ "$IGNORE_TEST_FAILURES" == "true" ]]; then
      log "Maven tests failed with exit code $mvn_status, but ignoring as requested."
    else
      final_status=$mvn_status
      log "Maven tests failed with exit code $mvn_status."
    fi
  fi

  if [[ $analyzer_status -ne 0 ]]; then
    if [[ $final_status -eq 0 ]]; then
      final_status=$analyzer_status
    fi
    log "Selenic analyzer failed with exit code $analyzer_status."
  fi

  if [[ $final_status -eq 0 ]]; then
    log "Completed successfully."
  else
    log "Completed with errors (exit code $final_status)."
  fi

  log "Report output: $REPORT_DIR"
  log "Data output: $SELENIC_DATA_DIR"

  exit $final_status
}

main "$@"
