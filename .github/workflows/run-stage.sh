#!/usr/bin/env bash
# run-stage.sh STAGE -- thin shim invoked by GitHub Classroom autograder.
# Defers to the autograde.yml workflow's logic.

set -euo pipefail

STAGE=${1:?usage: run-stage.sh phi|omega}

# In Classroom-autograder context, the docker container has been built
# already via autograde.yml; we just check whether the corresponding
# step succeeded by looking at $GITHUB_STEP_SUMMARY (best-effort) or
# by re-running the docker exec. For simplicity, re-run.

bash .devcontainer/seed.sh "${GITHUB_REPOSITORY:-test/test}" > /tmp/seed.env
# shellcheck disable=SC1091  # generated at runtime, not in repo
. /tmp/seed.env

case "$STAGE" in
  phi)
    docker run --rm --privileged \
      -v "$PWD/student:/student" \
      -e EXPECTED_FLAG="$FLAG1" \
      bo-lab bash -lc '
        gcc -m32 -fno-stack-protector -no-pie -z execstack \
            /student/exploit1.c -o /tmp/exploit1
        OUT=$(echo "cat /srv/flag1.txt; exit" | timeout 30 /tmp/exploit1 || true)
        echo "$OUT" | grep -F "$EXPECTED_FLAG" >/dev/null
      ' && echo "PASS: phi"
    ;;
  omega)
    docker run --rm --privileged \
      -v "$PWD/student:/student" \
      -e EXPECTED_FLAG="$FLAG2" \
      bo-lab bash -lc '
        gcc -m32 -fno-stack-protector -no-pie \
            /student/exploit2.c -o /tmp/exploit2
        OUT=$(echo "cat /srv/flag2.txt; exit" | timeout 30 /tmp/exploit2 || true)
        echo "$OUT" | grep -F "$EXPECTED_FLAG" >/dev/null
      ' && echo "PASS: omega"
    ;;
  *) echo "unknown stage: $STAGE" >&2; exit 2 ;;
esac
