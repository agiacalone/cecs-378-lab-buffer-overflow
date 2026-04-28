/* pledge.c — honor-pledge utility for the buffer-overflow lab.

   The student runs this before submission. It:
     1. Reads ~/.handle for the student's chosen handle.
     2. Composes the pledge text including handle and today's ISO date.
     3. Prints the pledge to stdout.
     4. Accepts the pledge re-entered verbatim on stdin.
     5. On exact match, cats /srv/honor.txt (mode 0400, owned by oracle).
     6. On mismatch or EOF, prints an error to stderr and exits 1.

   Setuid oracle so it can read /srv/honor.txt; opens the file while
   privileged, then drops privileges before reading. */

#include <err.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#define HANDLE_PATH      ".handle"
#define HONOR_FLAG_PATH  "/srv/honor.txt"
#define MAX_LINE         512

static char *
trim (char *s)
{
  size_t n = strlen (s);
  while (n > 0 && (s[n-1] == '\n' || s[n-1] == '\r' || s[n-1] == ' '))
    s[--n] = '\0';
  while (*s == ' ')
    ++s;
  return s;
}

static char *
read_handle (void)
{
  /* Look up student's home dir via passwd, not $HOME (we're setuid). */
  struct passwd *pw = getpwuid (getuid ());
  if (!pw)
    err (1, "getpwuid");

  char path[PATH_MAX];
  if (snprintf (path, sizeof path, "%s/%s", pw->pw_dir, HANDLE_PATH)
      >= (int) sizeof path)
    errx (1, "handle path too long");

  /* Drop to real uid for the .handle read.
     The handle file is mode 0600 owned by the student, and on Ubuntu
     22.04 /home/student is 0750 — neither readable nor traversable by
     oracle (our effective uid as a setuid binary). Save euid first and
     restore it after, so the subsequent /srv/honor.txt open in
     print_honor_flag still has oracle's privilege. */
  uid_t saved_euid = geteuid ();
  if (seteuid (getuid ()) != 0)
    err (1, "seteuid drop");

  FILE *f = fopen (path, "r");
  if (!f)
    errx (1, "no handle file at %s — run `make briefing` first", path);

  static char buf[128]; /* static: pointer remains valid after return (single call) */
  if (!fgets (buf, sizeof buf, f))
    {
      fclose (f);
      errx (1, "handle file is empty");
    }
  fclose (f);

  if (seteuid (saved_euid) != 0)
    err (1, "seteuid restore");

  char *h = trim (buf);
  if (*h == '\0')
    errx (1, "handle file is empty");
  return h;
}

static void
today_iso (char *out, size_t n)
{
  time_t now = time (NULL);
  struct tm tm;
  if (!localtime_r (&now, &tm))
    err (1, "localtime");
  if (strftime (out, n, "%Y-%m-%d", &tm) == 0)
    errx (1, "strftime");
}

static void
print_honor_flag (void)
{
  /* Open /srv/honor.txt while still privileged, drop privs, then read and print. */
  int fd = open (HONOR_FLAG_PATH, O_RDONLY);
  if (fd < 0)
    err (1, "open %s", HONOR_FLAG_PATH);

  /* Drop privileges. */
  if (setuid (getuid ()) != 0)
    err (1, "setuid");

  char buf[256];
  ssize_t r;
  while ((r = read (fd, buf, sizeof buf)) > 0)
    {
      ssize_t w = 0;
      while (w < r)
        {
          ssize_t k = write (STDOUT_FILENO, buf + w, (size_t)(r - w));
          if (k < 0)
            err (1, "write");
          w += k;
        }
    }
  if (r < 0)
    err (1, "read %s", HONOR_FLAG_PATH);
  close (fd);
}

int
main (int argc, char **argv)
{
  (void) argc;
  (void) argv;

  char *handle = read_handle ();
  char date[16];
  today_iso (date, sizeof date);

  /* The pledge text. Handle and date are the per-student variables. */
  char pledge[MAX_LINE];
  int n = snprintf (pledge, sizeof pledge,
                    "I, %s, on %s, affirm that the exploit code I have "
                    "committed to this repository was written by my own "
                    "hand. I read, understood, and chose every line. "
                    "I did not paste code I did not understand. I did "
                    "not have another person, tool, or model write my "
                    "exploit for me.",
                    handle, date);
  if (n < 0 || n >= (int) sizeof pledge)
    errx (1, "pledge composition failed");

  /* Print the pledge prominently with a separator. */
  fprintf (stderr,
           "\n--[ HONOR PLEDGE ]--\n\n"
           "Type the following pledge VERBATIM (one line) and press Enter:\n\n"
           "%s\n\n"
           "> ",
           pledge);

  /* Read one line from stdin. */
  char input[MAX_LINE];
  if (!fgets (input, sizeof input, stdin))
    errx (1, "pledge not affirmed");

  if (strcmp (trim (input), pledge) != 0)
    errx (1, "pledge not affirmed (typed text did not match)");

  fprintf (stderr, "\npledge affirmed.\n\n");
  print_honor_flag ();
  return 0;
}
