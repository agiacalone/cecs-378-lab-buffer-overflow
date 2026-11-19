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

readonly hh=$(printf '%s' "${repo}-honor" | sha256sum | cut -c1-32)

# Challenge flags (FLAG1/FLAG2) are NOT derived here: this script ships in the
# student repo, so any derived flag is precomputable and could be printf'd
# without exploiting. Flags are runtime-injected secrets (see entrypoint.sh for
# the dev value; grading overwrites with its own per-run random value).

printf 'BUFSZ=%s\n'      "$bufsz"
printf 'PADCOUNT=%s\n'   "$padcount"
printf 'HONOR_FLAG=CECS378{honor_%s}\n' "$hh"
