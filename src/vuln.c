/* vuln.c -- the deliberately vulnerable program for the buffer-overflow lab.
   DO NOT MODIFY. The autograder verifies this file's SHA-256.

   Compiled into vuln1 (Phase Phi) and vuln2 (Phase Omega) by build/Makefile,
   parameterized via -DBUFSZ=N -DPADCOUNT=K from .devcontainer/seed.sh.
   vuln2 additionally builds with -DLEAK_LIBC so it prints a libc symbol
   address: the foothold ret2libc needs under ASLR.

   I/O contract:
     - Writes the runtime address of `buffer` to stdout, flushed.
     - Writes the runtime address of the saved-EIP slot (this function's
       return-address slot on the stack) -- so the exploit doesn't have to
       guess the BUFSZ-to-saved-EIP distance from compiler-dependent
       padding/alignment.
     - With LEAK_LIBC, also writes the runtime address of printf().
     - Then reads up to ~8 KiB from stdin in one read().
     - Then memcpy()s the read bytes into `buffer` -- THE VULNERABILITY.
       memcpy (rather than strcpy) so NUL bytes in the payload are
       preserved: ret2libc payloads with small uid arguments (Phase Omega)
       contain NUL high bytes that strcpy would truncate.
     - Returns; corrupted saved EIP fires.

   Why leak-then-read: under ASLR (which we cannot disable in Codespaces),
   the only valid stack address for the saved-EIP overwrite is one observed
   in THIS process. Leaking via printf BEFORE the overflow in the same
   process is the realistic exploit shape and the lab's whole point.
   See phase-phi(7) and phase-omega(7). */

#include <err.h>
#include <inttypes.h>
#include <libgen.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifndef BUFSZ
# error "BUFSZ must be defined at compile time (see build/Makefile)"
#endif
#ifndef PADCOUNT
# error "PADCOUNT must be defined at compile time"
#endif
#ifndef PROGVERSION
# define PROGVERSION "2.0.0"
#endif

static const char *progname = "vuln";

static void
exploitable (void)
{
  char buffer[BUFSZ];
  volatile char padding[PADCOUNT * 16];
  (void) padding;

  printf ("[buffer @ %p, size %d, pad %d]\n",
          (void *) buffer, BUFSZ, PADCOUNT);
  /* Leak the saved-EIP slot location: __builtin_frame_address(0) returns
     the address of the saved EBP on x86; saved EIP lives 4 bytes higher.
     Without this, exploits would have to guess the distance from `buffer`
     to the saved-EIP slot (compiler-dependent due to local-variable
     layout, alignment, and red zones). */
  printf ("[saved-eip @ %p]\n",
          (void *) ((char *) __builtin_frame_address (0) + 4));
#ifdef LEAK_LIBC
  /* Cast through uintptr_t: function->object pointer conversion is
     conditionally supported in C, but POSIX guarantees it on platforms
     with dlsym(3). */
  printf ("[libc-printf @ 0x%" PRIxPTR "]\n", (uintptr_t) (void *) printf);
#endif
  fflush (stdout);

  /* Single read() so pipe atomicity (PIPE_BUF, 4096 on Linux) keeps the
     payload one contiguous chunk. Anything sent after the payload stays
     buffered for the post-exec /bin/sh to consume. */
  static char input[8192];
  ssize_t n = read (STDIN_FILENO, input, sizeof input);
  if (n < 0)
    err (1, "read");

  /* THE VULNERABILITY: memcpy of attacker-controlled length into a fixed
     stack buffer. memcpy (rather than strcpy) preserves NUL bytes in the
     payload -- needed by Phase Omega's ret2libc chain where small uid
     arguments contain NUL high bytes. The unbounded copy is the bug; do
     not "fix" it. */
  memcpy (buffer, input, (size_t) n);

  /* Use %.*s so a NUL inside the payload doesn't truncate the echo and so
     we don't read past what we actually copied. (Doesn't affect the
     exploit -- printf finishes and exploitable() returns into the
     overwritten saved EIP either way.) */
  printf ("you said: %.*s\n", (int) n, buffer);
}

static void
usage (FILE *stream)
{
  fprintf (stream,
           "Usage: %s\n"
           "       %s -h | --help\n"
           "       %s -V | --version\n"
           "Reads payload from stdin. Educational use only. See mainframe(7).\n",
           progname, progname, progname);
}

int
main (int argc, char **argv)
{
  progname = basename (argv[0]);

  if (argc > 1)
    {
      if (strcmp (argv[1], "-h") == 0 || strcmp (argv[1], "--help") == 0)
        {
          usage (stdout);
          return 0;
        }
      if (strcmp (argv[1], "-V") == 0 || strcmp (argv[1], "--version") == 0)
        {
          printf ("%s %s\n", progname, PROGVERSION);
          return 0;
        }
      usage (stderr);
      return 2;
    }

  exploitable ();
  return 0;
}
