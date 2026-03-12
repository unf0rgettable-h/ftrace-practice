#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAKE_ROOT="$PROJECT_ROOT/tmp/demo-tracing"

rm -rf "$FAKE_ROOT"
mkdir -p "$FAKE_ROOT"
printf 'nop\n' > "$FAKE_ROOT/current_tracer"
printf '0\n' > "$FAKE_ROOT/tracing_on"
: > "$FAKE_ROOT/set_ftrace_filter"
printf 'demo trace line 1\ndemo trace line 2\n' > "$FAKE_ROOT/trace"

run_demo() {
  LITETRACE_ROOT="$FAKE_ROOT" "$PROJECT_ROOT/litetrace" "$@"
}

echo '== status 之前 =='
run_demo status

echo
echo '== init =='
run_demo init

echo
echo '== 设置 filter =='
run_demo filter set vfs_write

echo
echo '== 打开 tracing =='
run_demo on
printf '<demo>-123 [000] .... 1.234: vfs_write <-ksys_write\n' >> "$FAKE_ROOT/trace"
printf '<demo>-123 [000] .... 1.235: vfs_write <-ksys_write\n' >> "$FAKE_ROOT/trace"

echo
echo '== 当前状态 =='
run_demo status

echo
echo '== dump =='
run_demo dump

echo
echo '== 关闭 tracing =='
run_demo off
