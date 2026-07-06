#!/usr/bin/env bats

setup() {
  # Put the aws mock stub on PATH
  export PATH="$BATS_TEST_DIRNAME/__mocks__:$PATH"
  local log; log="$(mktemp)"
  export AWS_LOG="$log"
}

teardown() {
  rm -f "$AWS_LOG"
}

@test "happy path: invalidates distribution" {
  export DISTRIBUTION_ID=E123ABC

  run bash "$BATS_TEST_DIRNAME/../core/publish-cloudfront-bucket.sh"

  [ "$status" -eq 0 ]
  grep -q 'cloudfront create-invalidation' "$AWS_LOG"
  grep -q -- '--distribution-id E123ABC' "$AWS_LOG"
  grep -q -- '--paths /\*' "$AWS_LOG"
}

@test "missing distribution id: hard error" {
  run bash "$BATS_TEST_DIRNAME/../core/publish-cloudfront-bucket.sh"

  [ "$status" -ne 0 ]
  # aws stub should not have been called — log stays empty
  [ ! -s "$AWS_LOG" ]
}
