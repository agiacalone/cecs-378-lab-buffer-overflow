#!/usr/bin/env bash
# entrypoint.sh — disable ASLR for the lab. Requires --privileged
# (set in devcontainer.json runArgs).
set -eu
if ! echo 0 > /proc/sys/kernel/randomize_va_space 2>/dev/null; then
  printf 'warning: could not disable ASLR; ' >&2
  # shellcheck disable=SC2016  # literal backticks for the user-facing hint
  printf 'wrap binaries with `setarch i686 -R` if exploits behave oddly.\n' >&2
fi
exec "$@"
