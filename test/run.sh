#!/usr/bin/env bash
# Offline test harness for core/publish-cloudfront-bucket.sh.
#
# Points an `aws` stub at PATH, runs the action script, and asserts on the invalidation
# call it makes / its exit code. No network, no real AWS.
#
# shellcheck disable=SC2015  # `cond && ok || bad` is intentional; ok() always returns 0
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$HERE/../core/publish-cloudfront-bucket.sh"
STUB_DIR="$HERE"   # contains the `aws` stub

pass=0
fail=0
note() { printf '  %s\n' "$*"; }
ok()   { pass=$((pass + 1)); printf 'ok   - %s\n' "$1"; }
bad()  { fail=$((fail + 1)); printf 'FAIL - %s\n' "$1"; [ -n "${2:-}" ] && note "$2"; }

# ---------------------------------------------------------------- tests

test_happy_path_invalidates_distribution() {
  local log; log="$(mktemp)"
  : >"$log"
  local out rc
  out="$(env PATH="$STUB_DIR:$PATH" AWS_LOG="$log" DISTRIBUTION_ID=E123ABC bash "$SCRIPT" 2>&1)"
  rc=$?

  [ "$rc" -eq 0 ] && ok "happy: exit 0 (green)" || bad "happy: exit 0 (green)" "rc=$rc out=$out"
  grep -q 'cloudfront create-invalidation' "$log" && ok "happy: create-invalidation called" || bad "happy: create-invalidation called" "$(cat "$log")"
  grep -q -- '--distribution-id E123ABC' "$log" && ok "happy: passes the distribution id" || bad "happy: passes the distribution id" "$(cat "$log")"
  grep -q -- '--paths /\*' "$log" && ok "happy: invalidates all paths" || bad "happy: invalidates all paths" "$(cat "$log")"

  rm -f "$log"
}

test_missing_distribution_id_hard_error() {
  local log; log="$(mktemp)"
  : >"$log"
  local out rc
  out="$(env PATH="$STUB_DIR:$PATH" AWS_LOG="$log" bash "$SCRIPT" 2>&1)"
  rc=$?

  [ "$rc" -ne 0 ] && ok "missing id: hard error (non-zero)" || bad "missing id: hard error (non-zero)" "rc=$rc out=$out"
  [ ! -s "$log" ] && ok "missing id: aws not invoked" || bad "missing id: aws not invoked" "$(cat "$log")"

  rm -f "$log"
}

# ---------------------------------------------------------------- run

test_happy_path_invalidates_distribution
test_missing_distribution_id_hard_error

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
