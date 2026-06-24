#!/usr/bin/env bash
# verify-seed.sh -- emit seed + binary fingerprints for the PR check.
# Used by autograder workflow as a non-secret diagnostic artifact.

set -euo pipefail

# shellcheck disable=SC1091  # generated at container build time, not in repo
. /opt/lab/seed.env

FP=$(printf '%s' "${BUFSZ}-${PADCOUNT}" | sha256sum | cut -c1-12)
H1=$(sha256sum /opt/lab/build/vuln1  | cut -c1-12)
H2=$(sha256sum /opt/lab/build/vuln2  | cut -c1-12)
HP=$(sha256sum /opt/lab/build/pledge | cut -c1-12)

printf 'seed-fingerprint: %s\n' "$FP"
printf 'vuln1-hash:       %s\n' "$H1"
printf 'vuln2-hash:       %s\n' "$H2"
printf 'pledge-hash:      %s\n' "$HP"
printf 'bufsz:            %s\n' "$BUFSZ"
printf 'padcount:         %s\n' "$PADCOUNT"
