#!/usr/bin/env bash

set -euo pipefail

: "${DISTRIBUTION_ID:?DISTRIBUTION_ID is required}"

aws cloudfront create-invalidation \
  --distribution-id "${DISTRIBUTION_ID}" \
  --paths "/*"
