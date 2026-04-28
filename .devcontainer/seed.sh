#!/usr/bin/env bash
# seed.sh — derive deterministic per-student build parameters from a string.
# Same input always produces the same output.
#
# Usage: seed.sh REPO_NAME
# Output: KEY=value lines on stdout.
# Exit:   0 on success, 2 on misuse, 1 on internal error.

# shellcheck disable=SC2155
set -euo pipefail

readonly progname=$(basename -- "$0")

usage() {
  printf 'Usage: %s REPO_NAME\n' "$progname" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

readonly repo=$1
readonly hash=$(printf '%s' "$repo" | sha256sum | cut -c1-16)
readonly n=$((16#$hash))

readonly bufsz_opts=(72 88 104 120)
readonly bufsz_idx=$(( (n % 4 + 4) % 4 ))
readonly bufsz=${bufsz_opts[$bufsz_idx]}
readonly padcount=$(( (((n % 5) + 5) % 5) + 1 ))

readonly h1=$(printf '%s' "${repo}-1"     | sha256sum | cut -c1-32)
readonly h2=$(printf '%s' "${repo}-2"     | sha256sum | cut -c1-32)
readonly hh=$(printf '%s' "${repo}-honor" | sha256sum | cut -c1-32)

printf 'BUFSZ=%s\n'      "$bufsz"
printf 'PADCOUNT=%s\n'   "$padcount"
printf 'FLAG1=CECS378{vuln1_%s}\n' "$h1"
printf 'FLAG2=CECS378{vuln2_%s}\n' "$h2"
printf 'HONOR_FLAG=CECS378{honor_%s}\n' "$hh"
