# Setup -- Codespaces (canonical path)

## Quickstart

1. Accept the GitHub Classroom assignment (your instructor's link).
2. From your assignment repo, click the green **Code** button → **Codespaces** → **Create codespace on main**.
3. **Wait.** First boot is **2 to 4 minutes** while Codespaces clones the repo, builds the devcontainer image, runs the verify-environment hook, and attaches you. The progress shows at the bottom of the VS Code window. Don't close the tab.
4. When the terminal hands you a `student@mainframe:~$` prompt with the dial-in banner, you are in.
5. Type `man mainframe`. That is your briefing.

## Pure CLI workflow (no browser, no VS Code)

If you want to live entirely in your terminal — create, attach, work, stop — here is the whole loop. Browser tabs opened: zero.

```sh
# One-time: install gh and authenticate.
brew install gh                            # or apt / dnf / winget
gh auth login

# Once per assignment, after accepting the Classroom invite in your
# browser (you can't avoid that step — it transfers the repo to you):
gh codespace create -R <your-username>/<your-assignment-repo> -b main
# Prints the codespace name when ready (~3 minutes for the first build).

# Every session after that:
gh codespace ssh                           # interactive picker
# or:  gh codespace ssh -c <codespace-name>

# Inside the box: do the lab. man mainframe, gdb, vi WRITEUP.md, etc.

# When you walk away:
gh codespace stop                          # picks from a menu
# or:  gh codespace stop -c <codespace-name>
```

Useful sister commands:

```sh
gh codespace list                          # what do I have running
gh codespace logs   -c <name>              # creation/start logs
gh codespace cp     <src> remote:<dst>     # scp through gh's tunnel
gh codespace ports  -c <name>              # forward, if you ever need to
gh codespace delete -c <name>              # nuke it (forces fresh build next time)
```

To skip the codespace name argument entirely on every command, set a default once: `gh codespace --help` shows the flags. Many people just script it: `alias bo='gh codespace ssh -c $BO_CS'` after exporting `BO_CS=<name>`.

## For the right feel: SSH from a real terminal

The browser Codespace is a VS Code window with a terminal panel. That works, but it is not what dialing into a Unix box felt like. For the canonical experience, after creating the Codespace, drop into it from your local terminal:

```sh
# install once: https://cli.github.com/
gh auth login         # if you haven't already
gh codespace ssh      # picks the Codespace from a menu
```

You land in a real terminal with the dial-in banner, the cyan box, and `student@mainframe:~$` looking back at you. **This is how every reference in this lab pictures you working.** The browser Codespace is a perfectly serviceable fallback if you cannot install `gh` locally.

To stop the codespace when you are done for the day (so you do not burn quota): `gh codespace stop` from your local terminal, or right-click in the GitHub Codespaces panel.

### Use any editor over Remote-SSH (VS Codium, JetBrains, Neovim, …)

The container ships an SSH server. To attach a local editor instead of the browser Codespace, dump the codespace into your SSH config once per session:

```sh
gh codespace ssh --config >> ~/.ssh/config
```

`gh` writes a `Host cs.<repo>.<branch>...` block with a `ProxyCommand` that tunnels through `gh`'s authenticated channel. Your editor never sees the tunnel — it just sees a normal SSH host.

| Editor | Extension | How to connect |
| --- | --- | --- |
| **VS Codium** | Remote - SSH (Open VSX) | `Cmd/Ctrl-Shift-P` → "Remote-SSH: Connect to Host…" → pick the `cs.…` entry |
| **VS Code (official)** | GitHub Codespaces extension | Codespaces panel → click the codespace |
| **JetBrains** | Gateway → SSH | Add new host → `cs.…` → open project at `/workspaces/<repo>` |
| **Neovim / Helix / Emacs** | TRAMP / sshfs / built-in remote | Connect to `cs.…` like any SSH host |
| **Pure terminal** | none | `gh codespace ssh` (interactive picker) |

The SSH path also lets you `scp`, `rsync`, run `tmux` over the connection, mount the workspace via `sshfs`, or use any other tool that talks SSH. Personal preference; the lab works the same way regardless.

## Codespaces details

- Codespaces VMs are always `linux/amd64` (x86-64 Linux), regardless of your laptop's architecture. M-series Mac, Intel Mac, Windows, Chromebook -- all see the same environment. **Codespaces is why this lab works on every host.**
- Free tier with GitHub Education includes ~180 hours/month. You will not exhaust it on this lab.
- **First boot: 2–4 minutes.** Codespaces clones, then runs ~28 docker build steps (apt install, gcc, pwntools, lab build, man pages, textfiles archive, …). The lower-right of VS Code shows progress; the build log is reachable via `Cmd/Ctrl-Shift-P` → "Codespaces: View Creation Log".
- **Subsequent restarts: ~30 seconds.** The image is already built; Codespaces just starts the container, runs `postStartCommand` (re-disables ASLR), and re-attaches.
- **Stopping a Codespace** suspends the VM (no quota burn while stopped). **Deleting** wipes the disk and forces a fresh build next time. Stop, don't delete, between sessions.
- ASLR (address-space randomization) is **on** in Codespaces — the platform's seccomp profile blocks the syscalls (`personality(2)`, kernel-knob writes) we'd otherwise use to disable it. This means stack base, mmap base, and libc base randomize across runs. The lab is designed around that:
  - Phase Φ: `vuln1` prints `&buffer` at runtime. Read the address from the program's own output and feed it back in your payload. Hard-coding a "static" address won't work.
  - Phase Ω: libc base randomizes too. Resolve `system` / `exit` / `"/bin/sh"` per-run via gdb on the binary, or via an intentional information leak from the program's output, before assembling the ret2libc payload.

## Where the lab lives

The repo is mounted at `/workspaces/<your-assignment-repo>/` (the
Codespaces convention) and a symlink at `~/lab` points to it. Either
path works — most students live in `~/lab`:

```sh
cd ~/lab
make briefing
```

The shell prompt is themed `student@mainframe:~$`, so being in your
home directory matches the dial-in vibe. (If you delete `~/lab` for
some reason, restarting the codespace recreates it via the
`postStartCommand` in the devcontainer.)

## Codespaces hygiene -- save your quota

Codespaces are billable cloud VMs. GitHub Education gives you
~180 core-hours/month, which is plenty for this lab if you stop
yours when you walk away. It is *not* infinite if you forget.

> **STOP, don't DELETE.**
>
> *Stop* pauses the VM with the disk intact: zero quota while
> stopped, instant resume next session, all your uncommitted work
> still there.
>
> *Delete* wipes everything: next session = fresh ~3-minute rebuild,
> AND any uncommitted edits are gone forever.
>
> The button labelled "Delete" is for when you want to start over
> from scratch. It is not for "I'm done for the day." If you walk
> away from the lab, hit **Stop**.

Habits that keep you in the safe zone:

- **Stop when you walk away.** Codespaces auto-suspend after about
  30 minutes idle, but stopping explicitly is faster and you can
  see at a glance that nothing is running:
  ```sh
  gh codespace stop                 # interactive picker
  ```
  Or right-click in the GitHub Codespaces panel → Stop. **Never
  click Delete unless you actually want a clean rebuild.**

- **`git commit && git push` is your save button.** If a Codespace
  ever does get deleted (by you, by a quota cap, by a platform
  hiccup), pushed commits live on GitHub and survive. Push every
  meaningful step, not just at the end.

- **Watch your usage.** `gh codespace list` shows everything you
  have running. Quota detail page:
  <https://github.com/settings/billing/summary>.

- **gdb time counts as active time.** Stepping through a debug
  session over lunch means hours of quota burn. Either stop the
  Codespace before you walk off (resume picks up where you left
  off), or set yourself a timer.

- **One Codespace per student per assignment.** Don't share — your
  seed is baked into your container, so a classmate's Codespace has
  a different flag, and the honor code is real.

If you do run out of quota mid-assignment: switch to local Docker
(`docs/setup-local.md`) or wait for the monthly reset. Local works
even when you still have quota — some students just prefer it.

## Troubleshooting

- **"environment not ready" / `verify-environment.sh` fails**: Rebuild the container. `Cmd/Ctrl-Shift-P` → "Codespaces: Rebuild Container."
- **Exploits behave oddly / segfault on benign input**: You probably bypassed the wrapper. Make sure you are calling `vuln1` (the wrapper on `PATH`), not `/opt/lab/build/vuln1` directly. The wrapper applies `setarch -R`, which is what makes the runtime address stable.
- **`make briefing` or `pledge` errors about `~/.handle`**: Run `make briefing` first; it will prompt for your handle on first invocation.
- **Codespace stuck in "recovery mode"**: usually a devcontainer config error. Open the creation log (Codespaces panel → Show Creation Log) and report the error to your instructor before rebuilding.

## When to use local Docker instead

Don't, unless you have a very good reason. See `docs/setup-local.md`.
