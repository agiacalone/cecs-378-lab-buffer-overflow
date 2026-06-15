#!/bin/bash
# Print the MAINFRAME banner once per container session on interactive
# shells. Use a /tmp marker so a fresh start of the codespace replays
# the banner (tmpfs is wiped at container restart) but rapid-fire
# additional shells stay quiet. Avoid ~/.hushlogin — that's a Unix
# convention for silencing system MOTD and many users' personal
# dotfiles ship one, which would suppress our banner unintentionally.

# Bail if not interactive.
case $- in *i*) ;; *) return ;; esac

# Bail if our session marker exists. Personal dotfiles can't accidentally
# create this name; it lives in /tmp which is tmpfs, so it resets on
# container restart.
_marker="/tmp/.mainframe-banner-shown-${USER:-$(id -un)}"
[ -f "$_marker" ] && { unset _marker; return; }

# ANSI color codes
ESC=$(printf '\033')
CYAN="${ESC}[36m"
RED="${ESC}[31m"
GRN="${ESC}[32m"
RST="${ESC}[0m"
BEL=$(printf '\007')

# Paced dial-up sequence
sleep 0.3
printf '\nATDT 5624851234\n'
sleep 0.4
printf '\nCONNECT 2400\n'
sleep 0.2
printf '%s' "$BEL"
sleep 0.4

# Banner
printf '%s' "$CYAN"
cat <<'BANNER'

       _________________________________________________________
      |                                                         |
      |   M A I N F R A M E    4 . 2   B S D                    |
      |   csulb-mainframe.edu                                   |
      |                                                         |
BANNER
printf '%s' "$RST"
printf '%s' "$CYAN"; printf '      |   '; printf '%s' "$RST"
printf '%s' "$RED";  printf 'PRIVATE SYSTEM.   AUTHORIZED USERS ONLY.            '; printf '%s' "$RST"
printf '%s' "$CYAN"; printf '|\n'
printf '      |   '
printf '%s' "$RED";  printf 'ALL ACTIVITY IS LOGGED AND MAY BE PROSECUTED        '; printf '%s' "$RST"
printf '%s' "$CYAN"; printf '|\n'
printf '      |   '
printf '%s' "$RED";  printf 'UNDER 18 U.S.C. SS 1030.                            '; printf '%s' "$RST"
printf '%s' "$CYAN"; printf '|\n'
cat <<'BANNER'
      |                                                         |
      |   System Operator:   sysop@csulb-mainframe.edu          |
      |   Maintenance:       Sunday 0200-0400 PST               |
      |_________________________________________________________|

BANNER
printf '%s' "$RST"

# Last login (themed)
printf 'Last login: Tue Apr 16 23:47:06 1991 from gw.lod.org\n\n'

# Sysop messages (green)
printf '%s' "$GRN"
printf '       sysop:  welcome, %s.\n' "$USER"
printf '       sysop:  briefing.  type:   man mainframe\n'
printf '       sysop:  good luck.\n'
printf '%s' "$RST"
printf '\n'

# fortune cookie from the sysop. Indented + cyan to match the
# banner aesthetic. Short fortunes only (-s) so it doesn't dominate
# the screen. Silently skip if fortune isn't installed.
if command -v fortune >/dev/null 2>&1; then
    printf '%s       --- fortune ---%s\n' "$CYAN" "$RST"
    fortune -s 2>/dev/null | sed 's/^/       /'
    printf '\n'
fi

# Touch the session marker so additional shells in this container are
# quiet. /tmp is tmpfs, so a container restart resets and the banner
# plays again — which is the right behavior for a "dial-in" feel.
touch "$_marker" 2>/dev/null
unset _marker
