---
real-name: <your name>
csulb-id: <your CSULB student ID>
handle: <your phreaker handle, your choice>
seed-fingerprint: <paste output of `make print-seed`>
flag1: <paste captured Phase Phi flag>
flag2: <paste captured Phase Omega flag>
honor-flag: <paste output of `pledge` after affirmation>
---

# After-Action Report -- Buffer Overflow Lab

[--[ 0.0 -- TARGET ]--]

> Where did you do this work (Codespace or local), and on what dates?
> Paste the line `make print-seed` printed in YOUR codespace.

[your answer]

[--[ 1.0 -- RECON ]--]

> Paste the output of these gdb commands run on YOUR vuln1 and vuln2.
> Show your work for finding the offset.
>
>     (gdb) info frame
>     (gdb) x/40wx $esp

[your gdb output and explanation]

[--[ 2.0 -- PHASE PHI ACE ]--]

> Walk through your `exploit1.c` step by step. Why those shellcode
> bytes? Why is the NOP sled the size it is? Where did the offset come
> from? Where in your code do you read the leaked `&buffer` from
> `vuln1`'s stdout, and how do you use it in the payload?

[your answer]

> Screenshots:
> ![Spawning the shell via Phase Phi](screenshots/phase-phi-shell.png)
> ![Reading flag1](screenshots/phase-phi-flag.png)

[--[ 3.0 -- PHASE OMEGA ACE ]--]

> Demonstrate that your Phase Phi exploit fails against vuln2. Paste
> the output (segfault, signal). Then explain in your own words: what
> changed in the binary, and why does that change make Phase Phi's
> approach unworkable?

[your answer]

> Walk through `exploit2.c`. How did you find the file offsets of
> `system`, `exit`, `setreuid`, and `/bin/sh` inside `libc.so.6`?
> Paste the commands you used. How did you compute the runtime libc
> base from the leaked `&printf`?

[your answer]

> Both `vuln1` and `vuln2` are setuid `oracle`. Explain in your own
> words why the naive `system("/bin/sh")` payload (or, in Phase Phi,
> the textbook `execve("/bin/sh")` shellcode) opens a shell that
> *cannot* read the flag, and what step you added to the chain (or
> shellcode) to fix it. Cite the relevant man pages.

[your answer]

> The Phase Omega chain needs a "pop pop ret" gadget to clean
> `setreuid`'s arguments off the stack between the two libc calls.
> How did you find one? Paste the address and the disassembly of the
> three instructions at that address.

[your answer]

> Screenshots:
> ![Spawning the shell via Phase Omega](screenshots/phase-omega-shell.png)
> ![Reading flag2](screenshots/phase-omega-flag.png)

[--[ 4.0 -- AFTERMATH ]--]

> Reflection (one short paragraph each):

- Which phase was harder, and why?
- The kernel ASLR **is** enabled here. Both phases defeated it via the
  leak-then-pwn pattern baked into `vuln1`/`vuln2`. Describe -- in your
  own words -- what would change about your exploits if the binaries
  did **not** print those addresses for you. (One paragraph; no need
  to implement.)
- Real software almost never disables stack canaries. If we had left
  the default canary on, what would your Phase Phi attack have
  triggered?
- Cite at least one of: Phrack 49:14, GNU Coding Standards, *The Art
  of Unix Programming*, or POSIX. Pick a section and explain why it
  is relevant to a security tool.

[your answers]

[--EOF--]
