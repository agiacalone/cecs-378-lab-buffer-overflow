# Build vuln1, vuln2 (from src/vuln.c) and pledge (from src/pledge.c).
# Per-student parameters come from /opt/lab/seed.env (generated at
# container build time by .devcontainer/seed.sh).

# Allow override for local development outside the container.
SEED_ENV ?= /opt/lab/seed.env

include $(SEED_ENV)
export BUFSZ PADCOUNT FLAG1 FLAG2 HONOR_FLAG

CC          := gcc
PROGVERSION := 2.0.0
CFLAGS_VULN := -m32 -fno-stack-protector -no-pie -g \
               -DBUFSZ=$(BUFSZ) -DPADCOUNT=$(PADCOUNT) \
               -DPROGVERSION=\"$(PROGVERSION)\"
CFLAGS_PLEDGE := -m32 -Wall -Wextra -Wconversion -O2

SRCDIR  := /opt/lab/src
BUILDDIR := /opt/lab/build

.PHONY: all briefing print-seed smoke clean

all: $(BUILDDIR)/vuln1 $(BUILDDIR)/vuln2 $(BUILDDIR)/pledge

$(BUILDDIR)/vuln1: $(SRCDIR)/vuln.c | $(BUILDDIR)
	$(CC) $(CFLAGS_VULN) -z execstack -o $@ $<

# vuln2 leaks a libc symbol address (printf) so ret2libc has a foothold
# under ASLR. See phase-omega(7).
$(BUILDDIR)/vuln2: $(SRCDIR)/vuln.c | $(BUILDDIR)
	$(CC) $(CFLAGS_VULN) -DLEAK_LIBC  -o $@ $<

$(BUILDDIR)/pledge: $(SRCDIR)/pledge.c | $(BUILDDIR)
	$(CC) $(CFLAGS_PLEDGE) -o $@ $<

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# print-seed: short fingerprint for the writeup frontmatter.
print-seed:
	@printf '%s\n' "$$(printf '%s' "$$BUFSZ-$$PADCOUNT-$$FLAG1" \
	    | sha256sum | cut -c1-6)"

# briefing: in-character assignment-briefing output + writes ~/.handle on
# first run if missing.
#
# Resolve the handle path via passwd, NOT $HOME. pledge(1) is setuid and
# uses getpwuid(getuid())->pw_dir to find the file; if we wrote to $HOME
# and Codespaces' shell environment has $HOME pointing somewhere else,
# briefing and pledge would disagree on where the handle lives.
briefing:
	@HFILE="$$(getent passwd $$(id -u) | cut -d: -f6)/.handle"; \
	if [ ! -f "$$HFILE" ]; then \
	    printf '\nfirst dial-in detected. choose your handle:\n> '; \
	    read -r handle; \
	    printf '%s\n' "$$handle" > "$$HFILE"; \
	    chmod 0600 "$$HFILE"; \
	    printf '\nhandle saved.\n\n'; \
	fi
	@HFILE="$$(getent passwd $$(id -u) | cut -d: -f6)/.handle"; \
	FP=$$(printf '%s' "$$BUFSZ-$$PADCOUNT-$$FLAG1" | sha256sum | cut -c1-6); \
	HANDLE=$$(cat "$$HFILE"); \
	printf '\n       [ MAINFRAME -- ASSIGNMENT BRIEFING -- DECRYPTING... ]\n\n'; \
	printf '       target system : mainframe (csulb-mainframe.edu)\n'; \
	printf '       your handle   : %s\n' "$$HANDLE"; \
	printf '       seed fp       : %s  (yours; do not share)\n\n' "$$FP"; \
	printf '       phase Phi    target  /opt/lab/build/vuln1\n'; \
	printf '                    walls   none.  this one is for warmup.\n'; \
	printf '                    flag    /srv/flag1.txt   (oracle: 0400)\n'; \
	printf '                    your buffer : %s bytes\n' "$$BUFSZ"; \
	printf '                    your padding: %s locals\n\n' "$$PADCOUNT"; \
	printf '       phase Omega  target  /opt/lab/build/vuln2\n'; \
	printf '                    walls   NX (executable stack disabled)\n'; \
	printf '                    flag    /srv/flag2.txt   (oracle: 0400)\n'; \
	printf '                    your buffer : %s bytes\n' "$$BUFSZ"; \
	printf '                    your padding: %s locals\n\n' "$$PADCOUNT"; \
	printf '       deliverables : student/exploit1.c\n'; \
	printf '                      student/exploit2.c\n'; \
	printf '                      student/WRITEUP.md   (with seed-fp %s,\n' "$$FP"; \
	printf '                                            flag1, flag2, honor-flag)\n'; \
	printf '                      student/screenshots/\n\n'; \
	printf '       before submit: run `pledge` and capture the honor flag.\n'; \
	printf '                      missing or wrong honor flag voids the\n'; \
	printf '                      submission.\n\n'; \
	printf '       sysop note   : `oracle` does not give up secrets willingly.\n'; \
	printf '                      `oracle` will, however, do whatever vuln1 and\n'; \
	printf '                      vuln2 ask, because vuln1 and vuln2 are setuid.\n'; \
	printf '                      this is what you will exploit.\n\n'; \
	printf '                                                             -- EOF\n\n'

# smoke: pipe benign input on stdin, confirm vuln1/vuln2 don't segfault.
smoke: all
	@printf 'hello' | $(BUILDDIR)/vuln1 >/dev/null && echo "smoke: vuln1 ok"
	@printf 'hello' | $(BUILDDIR)/vuln2 >/dev/null && echo "smoke: vuln2 ok"

clean:
	rm -f $(BUILDDIR)/vuln1 $(BUILDDIR)/vuln2 $(BUILDDIR)/pledge
