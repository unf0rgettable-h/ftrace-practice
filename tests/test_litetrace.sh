#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$PROJECT_ROOT/litetrace"
TEST_TMP="$PROJECT_ROOT/tmp/test-env"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    fail "expected output to contain [$needle], got: $haystack"
  fi
}

assert_eq() {
  local actual="$1"
  local expected="$2"
  if [[ "$actual" != "$expected" ]]; then
    fail "expected [$expected], got [$actual]"
  fi
}

reset_fake_tracing() {
  rm -rf "$TEST_TMP"
  mkdir -p "$TEST_TMP"
  printf 'nop\n' > "$TEST_TMP/current_tracer"
  printf '0\n' > "$TEST_TMP/tracing_on"
  : > "$TEST_TMP/set_ftrace_filter"
  printf '# fake trace\n' > "$TEST_TMP/trace"
}

run_cmd() {
  LITETRACE_ROOT="$TEST_TMP" "$SCRIPT" "$@"
}

test_status_shows_current_values() {
  reset_fake_tracing
  printf 'function\n' > "$TEST_TMP/current_tracer"
  printf '1\n' > "$TEST_TMP/tracing_on"
  printf 'vfs_write\n' > "$TEST_TMP/set_ftrace_filter"

  local output
  output="$(run_cmd status)"

  assert_contains "$output" 'current_tracer: function'
  assert_contains "$output" 'tracing_on: 1'
  assert_contains "$output" 'set_ftrace_filter: vfs_write'
}

test_on_and_off_change_tracing_switch() {
  reset_fake_tracing

  run_cmd on >/dev/null
  assert_eq "$(tr -d '\n' < "$TEST_TMP/tracing_on")" '1'

  run_cmd off >/dev/null
  assert_eq "$(tr -d '\n' < "$TEST_TMP/tracing_on")" '0'
}

test_filter_set_and_clear_change_filter_file() {
  reset_fake_tracing

  run_cmd filter set vfs_write >/dev/null
  assert_eq "$(tr -d '\n' < "$TEST_TMP/set_ftrace_filter")" 'vfs_write'

  run_cmd filter clear >/dev/null
  assert_eq "$(cat "$TEST_TMP/set_ftrace_filter")" ''
}

test_init_sets_function_mode_and_clears_trace() {
  reset_fake_tracing
  printf 'old line\n' > "$TEST_TMP/trace"

  run_cmd init >/dev/null

  assert_eq "$(tr -d '\n' < "$TEST_TMP/current_tracer")" 'function'
  assert_eq "$(tr -d '\n' < "$TEST_TMP/tracing_on")" '0'
  assert_eq "$(cat "$TEST_TMP/trace")" ''
}

test_clear_empties_trace_file() {
  reset_fake_tracing
  printf 'leftover data\n' > "$TEST_TMP/trace"

  run_cmd clear >/dev/null

  assert_eq "$(cat "$TEST_TMP/trace")" ''
}

test_dump_prints_trace_content() {
  reset_fake_tracing
  printf 'line one\nline two\n' > "$TEST_TMP/trace"

  local output
  output="$(run_cmd dump)"

  assert_contains "$output" 'line one'
  assert_contains "$output" 'line two'
}

main() {
  test_status_shows_current_values
  test_on_and_off_change_tracing_switch
  test_filter_set_and_clear_change_filter_file
  test_init_sets_function_mode_and_clears_trace
  test_clear_empties_trace_file
  test_dump_prints_trace_content
  echo 'PASS: all tests passed'
}

main "$@"
