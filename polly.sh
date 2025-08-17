#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[INFO] Welcome to Polly (the rego policy tester)"

usage() {
  echo "Usage: "
  echo "  $0 all                        # Run all tests"
  echo "  $0 list                       # List available services/entities"
  echo "  $0 <path>                     # Run tests for a specific policy file, entity, service, or directory"
  echo "  [--coverage <output.json>]    # Output coverage report to JSON file (do not use with --verbose)"
  echo "  [--verbose]                   # Optional: verbose output (do not use with --coverage)"
  exit 1
}

# Parse optional flags
COVERAGE=""
COVERAGE_OUT=""
VERBOSE=""
VERBOSE_OUT=""
ARGS=()
i=1
while [ $i -le $# ]; do
  arg="${!i}"
  case $arg in
    --coverage)
      COVERAGE="--coverage"
      next=$((i+1))
      if [ $next -le $# ] && [[ "${!next}" != --* ]] && [[ "${!next}" != all ]] && [[ "${!next}" != list ]]; then
        COVERAGE_OUT="${!next}"
        i=$((i+1))
      fi
      ;;
    --verbose)
      VERBOSE="-v"
      next=$((i+1))
      if [ $next -le $# ] && [[ "${!next}" != --* ]] && [[ "${!next}" != all ]] && [[ "${!next}" != list ]]; then
        VERBOSE_OUT="${!next}"
        i=$((i+1))
      fi
      ;;
    all|list)
      ARGS+=("$arg")
      ;;
    *)
      # Only add non-flag args (like policy path)
      if [[ $arg != --* ]]; then
        ARGS+=("$arg")
      fi
      ;;
  esac
  i=$((i+1))
done

# Prevent using both --coverage and --verbose together
if [[ -n "$COVERAGE" && -n "$VERBOSE" ]]; then
  echo "[WARN] --coverage and --verbose should not be used together. Ignoring --verbose."
  VERBOSE=""
  VERBOSE_OUT=""
fi

# Warn if --coverage or --verbose is used without an output file
if [[ -n "$COVERAGE" && -z "$COVERAGE_OUT" ]]; then
  echo "[WARN] --coverage output will be printed to stdout."
fi
if [[ -n "$VERBOSE" && -z "$VERBOSE_OUT" ]]; then
  echo "[WARN] --verbose output will be printed to stdout."
fi

# If coverage is set, allow output file to be optional (print to stdout if not supplied)

case "${ARGS[0]:-}" in
  all)
    echo "[INFO] Running all tests..."
    if [[ -n "$COVERAGE" ]]; then
      if [[ -n "$COVERAGE_OUT" ]]; then
        ./opa test $COVERAGE --format json "$ROOT_DIR/policies" "$ROOT_DIR/tests" "$ROOT_DIR/test_data" > "$COVERAGE_OUT"
      else
        ./opa test $COVERAGE --format json "$ROOT_DIR/policies" "$ROOT_DIR/tests" "$ROOT_DIR/test_data"
      fi
    elif [[ -n "$VERBOSE_OUT" ]]; then
      ./opa test $VERBOSE "$ROOT_DIR/policies" "$ROOT_DIR/tests" "$ROOT_DIR/test_data" > "$VERBOSE_OUT"
    else
      ./opa test $VERBOSE "$ROOT_DIR/policies" "$ROOT_DIR/tests" "$ROOT_DIR/test_data"
    fi
    ;;
  list)
    echo "[INFO] Available services:"
    find "$ROOT_DIR/policies" -mindepth 1 -maxdepth 1 -type d | sed "s|$ROOT_DIR/policies/|  |"
    echo
    echo "[INFO] Available entities:"
    find "$ROOT_DIR/policies" -mindepth 2 -maxdepth 2 -type d | sed "s|$ROOT_DIR/policies/|  |"
    ;;
  "")
    usage
    ;;
  *)
    POLICY_PATH="${ARGS[0]}"
    # Remove trailing slash if present
    POLICY_PATH="${POLICY_PATH%/}"
    POLICY_DIR="$ROOT_DIR/policies/$POLICY_PATH"
    TEST_DIR="$ROOT_DIR/tests/$POLICY_PATH"
    if [ -d "$POLICY_DIR" ]; then
      # Directory: run all .rego files recursively in this dir
      mapfile -t POLICY_FILES < <(find "$POLICY_DIR" -type f -name '*.rego')
      mapfile -t TEST_FILES < <(find "$TEST_DIR" -type f -name '*.rego')
      echo "[INFO] Running tests for all policies in $POLICY_PATH (recursively)..."
      if [[ ${#POLICY_FILES[@]} -eq 0 && ${#TEST_FILES[@]} -eq 0 ]]; then
        echo "No .rego files found in $POLICY_DIR or $TEST_DIR."
        exit 1
      fi
      if [[ -n "$COVERAGE" ]]; then
        if [[ -n "$COVERAGE_OUT" ]]; then
          ./opa test $COVERAGE --format json "${POLICY_FILES[@]}" "${TEST_FILES[@]}" "$ROOT_DIR/test_data" > "$COVERAGE_OUT"
        else
          ./opa test $COVERAGE --format json "${POLICY_FILES[@]}" "${TEST_FILES[@]}" "$ROOT_DIR/test_data"
        fi
      elif [[ -n "$VERBOSE_OUT" ]]; then
        ./opa test $VERBOSE "${POLICY_FILES[@]}" "${TEST_FILES[@]}" "$ROOT_DIR/test_data" > "$VERBOSE_OUT"
      else
        ./opa test $VERBOSE "${POLICY_FILES[@]}" "${TEST_FILES[@]}" "$ROOT_DIR/test_data"
      fi
    else
      # Single file
      echo "[INFO] Running tests for policy $POLICY_PATH..."
      POLICY_FILE="$ROOT_DIR/policies/$POLICY_PATH.rego"
      TEST_FILE="$ROOT_DIR/tests/$POLICY_PATH.rego"
      if [[ -n "$COVERAGE" ]]; then
        if [[ -n "$COVERAGE_OUT" ]]; then
          ./opa test $COVERAGE --format json "$POLICY_FILE" "$TEST_FILE" "$ROOT_DIR/test_data" > "$COVERAGE_OUT"
        else
          ./opa test $COVERAGE --format json "$POLICY_FILE" "$TEST_FILE" "$ROOT_DIR/test_data"
        fi
      elif [[ -n "$VERBOSE_OUT" ]]; then
        ./opa test $VERBOSE "$POLICY_FILE" "$TEST_FILE" "$ROOT_DIR/test_data" > "$VERBOSE_OUT"
      else
        ./opa test $VERBOSE "$POLICY_FILE" "$TEST_FILE" "$ROOT_DIR/test_data"
      fi
    fi
    ;;
esac