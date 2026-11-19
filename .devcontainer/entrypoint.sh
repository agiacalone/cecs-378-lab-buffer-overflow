#!/usr/bin/env bash
# entrypoint.sh -- container init for the buffer-overflow lab.
#
# ASLR stays ON: the lab is "leak-then-pwn" by design, and the
# /proc/sys/kernel/randomize_va_space write fails under Codespaces/CI seccomp
# anyway, so we no longer attempt it.
#
# Challenge flags are NOT seeded here. The image runs as USER `student`, which
# cannot chown a file to `oracle`; dev flags are instead baked (as root) at
# build time with a RANDOM, non-derivable value. At grading time gradebox
# tmpfs-mounts /srv and injects its own per-round random secret, shadowing the
# baked dev value. So this entrypoint is a thin passthrough.
set -eu
exec "$@"
