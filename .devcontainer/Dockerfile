FROM --platform=linux/amd64 ubuntu:22.04

# Use bash for all RUN commands. The default /bin/sh is dash on Ubuntu,
# which does NOT support $'\t' ANSI-C quoting; the textfiles MANIFEST.tsv
# loop relies on a real TAB IFS, and dash silently turns $'\t' into the
# literal characters \t — splitting paths like "foo.txt" on the letter t.
SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
# DEBIAN_FRONTEND is an ARG, not an ENV — it scopes to the build only.
# Setting it as an ENV would persist into runtime and show in `docker
# inspect`, which we don't want.
#
# ARG SEED is intentionally declared LATER in this Dockerfile, right
# before its first use, so that changing SEED between builds does not
# invalidate the cache for the heavy apt-install layer (~1 GB) and
# all the layers that follow it. Each per-seed build then reuses the
# base image cache and only rebuilds the seed-derived bits at the end.

# Ubuntu's minimal image strips /usr/share/man, /usr/share/doc, and
# /usr/share/info via dpkg excludes; /usr/bin/man is replaced with a
# stub that just prints "this system has been minimized." Ubuntu ships
# /usr/local/sbin/unminimize which removes the excludes AND reinstalls
# every already-present package with its docs intact. Run BEFORE
# adding our own packages so they install with docs too.
RUN yes | /usr/local/sbin/unminimize 2>&1 | tail -5

# 32-bit toolchain + standard exploitation utilities + man infrastructure.
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential gcc-multilib libc6-dev-i386 \
      gdb python3 python3-pip git make file \
      strace ltrace xxd vim nano less sudo \
      man-db manpages manpages-dev manpages-posix manpages-posix-dev \
      ca-certificates curl \
      mlocate tree \
      bsd-mailx bsdgames fortune-mod fortunes \
    && rm -rf /var/lib/apt/lists/*

# Optional teaching aid; not required for the lab.
RUN pip3 install --no-cache-dir pwntools==4.13.1

# Two unprivileged users: 'student' (interactive) and 'oracle' (owns flags).
RUN useradd --create-home --shell /bin/bash student \
 && useradd --create-home --shell /usr/sbin/nologin oracle

# Themed surfaces
COPY etc/issue                           /etc/issue
COPY etc/motd-old                        /etc/motd-old
COPY etc/profile.d/00-mainframe-banner.sh /etc/profile.d/00-mainframe-banner.sh
COPY etc/profile.d/01-mainframe-prompt.sh /etc/profile.d/01-mainframe-prompt.sh
COPY etc/update-motd.d/99-mainframe-banner /etc/update-motd.d/99-mainframe-banner
COPY var/spool/mail/student              /var/spool/mail/student
RUN chmod +x /etc/profile.d/00-mainframe-banner.sh \
              /etc/profile.d/01-mainframe-prompt.sh \
              /etc/update-motd.d/99-mainframe-banner \
 && chown root:mail /var/spool/mail/student 2>/dev/null \
    || chown root:root /var/spool/mail/student \
 && chmod 0660 /var/spool/mail/student \
 && chown student /var/spool/mail/student

# Suppress Ubuntu's stock login chrome so only the dial-in banner shows.
# Ubuntu's pam_motd runs every executable in /etc/update-motd.d/ in lex
# order, then concatenates /etc/motd, then prints /etc/legal once. The
# stock 00-header / 10-help-text / 50-motd-news / 9?-* scripts print
# "Welcome to Ubuntu...", help URLs, MOTD news, and "N updates available"
# — all wrong era. /etc/motd would re-print our banner box statically.
# /etc/legal prints the BSD-style warranty notice.
#
# Strategy: remove every stock update-motd.d script (keeping only our
# 99-mainframe-banner), truncate /etc/motd and /etc/legal to empty.
RUN find /etc/update-motd.d -mindepth 1 -maxdepth 1 \
        ! -name '99-mainframe-banner' -exec rm -f {} + \
 && : > /etc/motd \
 && : > /etc/legal

# VS Code in Codespaces opens terminals as non-login shells, which means
# /etc/profile.d/*.sh would not be sourced. Wire /etc/bash.bashrc (which
# IS sourced for non-login interactive shells) to load our banner and
# prompt scripts. The banner script's own .hushlogin guard ensures it
# only fires once per session.
RUN cat >> /etc/bash.bashrc <<'BASHRC'

# CECS 378 lab: source mainframe profile.d scripts on interactive
# (including non-login) shells. Codespaces' VS Code terminal is the
# usual case where this matters. (SSH login shells get profile.d
# automatically via /etc/profile.)
case $- in *i*)
  for _f in /etc/profile.d/00-mainframe-banner.sh /etc/profile.d/01-mainframe-prompt.sh; do
    [ -r "$_f" ] && . "$_f"
  done
  unset _f
  ;;
esac
BASHRC

# Lab tree
RUN mkdir -p /opt/lab/src /opt/lab/build /srv

# Sources
COPY src/ /opt/lab/src/
COPY build/ /opt/lab/build/
COPY .devcontainer/seed.sh /opt/lab/seed.sh
COPY tests/ /opt/lab/tests/

# Declare SEED here so it only invalidates the cache from this RUN
# onwards. Per-seed soak builds then share the heavy apt-install /
# user-creation / textfile-staging layers above.
ARG SEED=default-seed-not-set
ENV SEED=${SEED}

# Derive seed.env from build-time SEED arg.
# Do NOT `cat` seed.env here — FLAG1/FLAG2/HONOR_FLAG would land in the
# docker build log and leak to anyone with read access to build artifacts.
RUN bash /opt/lab/seed.sh "${SEED}" > /opt/lab/seed.env

# Build vuln1, vuln2, pledge from the seed-derived params.
RUN make -C /opt/lab/build all SEED_ENV=/opt/lab/seed.env

# Honor flag baked read-only. Challenge flags are baked as a RANDOM,
# non-derivable dev value (NOT seed-derived, so nothing is precomputable) so a
# student can iterate locally. At grading time gradebox tmpfs-mounts /srv and
# injects a fresh per-round random secret, shadowing these. Values are written
# to files (never echoed) so nothing lands in the build log.
RUN . /opt/lab/seed.env \
 && echo "${HONOR_FLAG}" > /srv/honor.txt \
 && printf 'CECS378{vuln1_%s}\n' "$(od -An -tx1 -N16 /dev/urandom | tr -d ' \n')" > /srv/flag1.txt \
 && printf 'CECS378{vuln2_%s}\n' "$(od -An -tx1 -N16 /dev/urandom | tr -d ' \n')" > /srv/flag2.txt \
 && chown oracle:oracle /srv/flag1.txt /srv/flag2.txt /srv/honor.txt \
 && chmod 0400         /srv/flag1.txt /srv/flag2.txt /srv/honor.txt

# Setuid the targets and pledge utility.
RUN chown oracle:oracle /opt/lab/build/vuln1 /opt/lab/build/vuln2 /opt/lab/build/pledge \
 && chmod 4755          /opt/lab/build/vuln1 /opt/lab/build/vuln2 /opt/lab/build/pledge

# Symlinks on PATH for the setuid binaries.
#
# Earlier revisions wrapped these with `setarch -R` to disable ASLR
# per-process. Codespaces' seccomp profile blocks personality(2)
# entirely, so setarch fails with "Operation not permitted" with or
# without an arch arg. We accept ASLR-on for now.
#
# What that means for the lab:
# - Phase Φ (vuln1) still works — vuln1 prints &buffer at runtime, so
#   the student's exploit reads the address from each run before
#   crafting the payload. Stack-base randomization is irrelevant when
#   you observe the address you're about to overwrite.
# - Phase Ω (vuln2 / ret2libc) is harder because libc base randomizes.
#   If this proves unworkable in the field, the next revision should
#   add an intentional libc info-leak to vuln2's normal output (a
#   printf of, say, &system) so students can compute libc base.
RUN ln -sf /opt/lab/build/vuln1  /usr/local/bin/vuln1 \
 && ln -sf /opt/lab/build/vuln2  /usr/local/bin/vuln2 \
 && ln -sf /opt/lab/build/pledge /usr/local/bin/pledge

# Man pages
COPY man/ /usr/local/share/man/staging/
RUN mkdir -p /usr/local/share/man/man1 \
             /usr/local/share/man/man7 \
             /usr/local/share/man/man8 \
 && for f in /usr/local/share/man/staging/*.1; do gzip -f "$f" || true; done \
 && for f in /usr/local/share/man/staging/*.7; do gzip -f "$f" || true; done \
 && for f in /usr/local/share/man/staging/*.8; do gzip -f "$f" || true; done \
 && mv /usr/local/share/man/staging/*.1.gz /usr/local/share/man/man1/ 2>/dev/null || true \
 && mv /usr/local/share/man/staging/*.7.gz /usr/local/share/man/man7/ 2>/dev/null || true \
 && mv /usr/local/share/man/staging/*.8.gz /usr/local/share/man/man8/ 2>/dev/null || true \
 && rm -rf /usr/local/share/man/staging \
 && mandb -q

# Textfiles archive — driven by etc/textfiles/MANIFEST.tsv.
# Verify each row's SHA sidecar before placing the file. mkdir -p the
# target dir, copy into place, rename uucp-textfiles-INDEX -> INDEX.
COPY etc/textfiles/ /opt/textfiles-staging/
RUN useradd --create-home --shell /usr/sbin/nologin sysop 2>/dev/null || true \
 && set -eu; \
    while IFS=$'\t' read -r relpath target category url desc; do \
      case "$relpath" in '#'*|'') continue ;; esac; \
      src="/opt/textfiles-staging/${relpath}"; \
      sha_sidecar="${src}.sha256"; \
      [ -f "$src" ] || { echo "manifest missing $relpath" >&2; exit 1; }; \
      [ -f "$sha_sidecar" ] || { echo "missing sha sidecar for $relpath" >&2; exit 1; }; \
      echo "$(cat "$sha_sidecar")  $src" | sha256sum -c - >/dev/null \
        || { echo "sha mismatch for $relpath" >&2; exit 1; }; \
      mkdir -p "$target"; \
      basename_only=$(basename "$relpath"); \
      [ "$basename_only" = "uucp-textfiles-INDEX" ] && basename_only=INDEX; \
      cp "$src" "${target}/${basename_only}"; \
    done < /opt/textfiles-staging/MANIFEST.tsv \
 && chown -R sysop:sysop /home/sysop 2>/dev/null || chown -R root:root /home/sysop \
 && rm -rf /opt/textfiles-staging \
 && updatedb

# Entrypoint disables ASLR (privileged).
COPY .devcontainer/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER student
WORKDIR /workspaces

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
