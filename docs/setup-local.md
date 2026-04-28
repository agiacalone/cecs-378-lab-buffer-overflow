# Setup -- Local Docker (advanced; unsupported)

This is the appendix path. Codespaces (`docs/setup.md`) is the supported path. Local Docker is documented for the few students who, for whatever reason, want to run the lab on their own machine.

## You will not get help here

If your local setup breaks and Codespaces would have worked, the answer is "use Codespaces."

## Apple Silicon (M-series Mac)

Local Docker on M-series runs x86-64 containers under QEMU user-mode emulation. Exploitation work is the worst case for QEMU: signal delivery and segfault timing can drift from real x86. **Stage 2 sometimes faults differently than on real hardware.** When that happens, the answer is Codespaces.

## VS Code Dev Containers extension

1. Install Docker Desktop.
2. Install the **Dev Containers** extension in VS Code.
3. Clone your assignment repo locally.
4. `Cmd/Ctrl-Shift-P` → "Dev Containers: Reopen in Container."
5. Wait. The first build takes 1–3 minutes locally.

## `devcontainer up` CLI

If you don't use VS Code, install the [devcontainers CLI](https://github.com/devcontainers/cli) and run:

```bash
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash
```

## Linux without Docker?

Not supported. The lab depends on `--privileged` and `kernel.randomize_va_space=0` and a 32-bit toolchain in a known state. Use Docker.
