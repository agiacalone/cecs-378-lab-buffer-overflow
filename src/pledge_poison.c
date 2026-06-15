#include "pledge_poison.h"
#include <string.h>

/* Poison codepoints as UTF-8 byte sequences. The detection set is a superset
   of what poison_pledge injects, so a copy survives even if a terminal strips
   the zero-width layer (the homoglyphs still trip it), or vice versa. */
static const char *const POISON[] = {
  "\xE2\x80\x8B", /* U+200B ZERO WIDTH SPACE      (injected) */
  "\xE2\x81\xA0", /* U+2060 WORD JOINER */
  "\xEF\xBB\xBF", /* U+FEFF ZERO WIDTH NO-BREAK SPACE */
  "\xD0\xB0",     /* U+0430 a  (injected for 'a') */
  "\xD0\xBE",     /* U+043E o  (injected for 'o') */
  "\xD0\xB5",     /* U+0435 e  (injected for 'e') */
  "\xD1\x81",     /* U+0441 c  (injected for 'c') */
  "\xD1\x80",     /* U+0440 p  (injected for 'p') */
  NULL
};

/* Zero-width space injected after each ASCII space. */
static const char ZWSP[] = "\xE2\x80\x8B";

int
contains_poison (const char *s)
{
  for (size_t i = 0; POISON[i] != NULL; i++)
    if (strstr (s, POISON[i]) != NULL)
      return 1;
  return 0;
}

/* Cyrillic homoglyph for a lowercase ASCII char, or NULL if none. */
static const char *
homoglyph (char c)
{
  switch (c)
    {
    case 'a': return "\xD0\xB0";
    case 'o': return "\xD0\xBE";
    case 'e': return "\xD0\xB5";
    case 'c': return "\xD1\x81";
    case 'p': return "\xD1\x80";
    default:  return NULL;
    }
}

int
poison_pledge (const char *clean, char *out, size_t outsz)
{
  size_t o = 0;

  for (size_t i = 0; clean[i] != '\0'; i++)
    {
      char c = clean[i];
      const char *g = homoglyph (c);

      if (g != NULL)
        {
          size_t glen = strlen (g);
          if (o + glen >= outsz)
            return -1;
          memcpy (out + o, g, glen);
          o += glen;
        }
      else
        {
          if (o + 1 >= outsz)
            return -1;
          out[o++] = c;
        }

      if (c == ' ')
        {
          size_t zlen = sizeof ZWSP - 1;
          if (o + zlen >= outsz)
            return -1;
          memcpy (out + o, ZWSP, zlen);
          o += zlen;
        }
    }

  if (o >= outsz)
    return -1;
  out[o] = '\0';
  return 0;
}

verdict_t
classify (const char *input, const char *clean)
{
  if (contains_poison (input))
    return V_PASTE_DETECTED;
  if (strcmp (input, clean) == 0)
    return V_AFFIRMED;
  return V_MISMATCH;
}
