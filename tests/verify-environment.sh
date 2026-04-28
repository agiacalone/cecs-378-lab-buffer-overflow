#!/usr/bin/env bash
# verify-environment.sh -- run as postCreateCommand. Confirms the lab
# is set up correctly and prints a green-check on success.

set -euo pipefail

progname=$(basename -- "$0")
readonly progname

fail() {
  printf '%s: FAIL: %s\n' "$progname" "$1" >&2
  exit 1
}

# 32-bit toolchain
command -v gcc >/dev/null || fail "gcc not on PATH"
echo 'int main(void){return 0;}' | gcc -m32 -x c - -o /tmp/_check_m32 \
  || fail "gcc -m32 cannot compile"
rm -f /tmp/_check_m32

# Lab files
[[ -f /opt/lab/build/vuln1  ]] || fail "missing /opt/lab/build/vuln1"
[[ -f /opt/lab/build/vuln2  ]] || fail "missing /opt/lab/build/vuln2"
[[ -f /opt/lab/build/pledge ]] || fail "missing /opt/lab/build/pledge"
[[ -f /srv/flag1.txt        ]] || fail "missing /srv/flag1.txt"
[[ -f /srv/flag2.txt        ]] || fail "missing /srv/flag2.txt"
[[ -f /srv/honor.txt        ]] || fail "missing /srv/honor.txt"

# Setuid bits
for b in /opt/lab/build/vuln1 /opt/lab/build/vuln2 /opt/lab/build/pledge; do
  perm=$(stat -c '%a' "$b")
  case "$perm" in
    4*) ;;
    *) fail "$b is not setuid (mode=$perm)" ;;
  esac
done

# Smoke
/opt/lab/build/vuln1 hello >/dev/null \
  || fail "vuln1 segfaults on benign input"
/opt/lab/build/vuln2 hello >/dev/null \
  || fail "vuln2 segfaults on benign input"

# Man pages
for page in mainframe phase-phi phase-omega gdb-quickref vuln1 vuln2 pledge oracle; do
  man -w "$page" >/dev/null 2>&1 \
    || fail "man page $page not installed"
done

# Pretty success banner
GRN=$(printf '\033[32m'); RST=$(printf '\033[0m')
# shellcheck disable=SC2016  # literal backticks for the user-facing hint
printf '\n%s[ environment ready ]%s -- type `man mainframe`.\n\n' "$GRN" "$RST"
