#ifndef PLEDGE_POISON_H
#define PLEDGE_POISON_H

#include <stddef.h>

/* Verdict for a re-entered honor pledge. */
typedef enum {
  V_AFFIRMED,        /* input is the clean ASCII pledge, hand-typed */
  V_PASTE_DETECTED,  /* input carries injected poison codepoints (a paste) */
  V_MISMATCH         /* neither: a genuine typo */
} verdict_t;

/* All pointer arguments to the functions below must be non-NULL;
   behavior is undefined otherwise. */

/* Build a poisoned, display-only render of `clean` into `out` (NUL-terminated).
   Substitutes Cyrillic homoglyphs for lowercase a/o/e/c/p and inserts a U+200B
   zero-width space after every ASCII space. Returns 0 on success, -1 if `out`
   (size `outsz`) is too small. */
int poison_pledge (const char *clean, char *out, size_t outsz);

/* Return 1 if `s` contains any known poison codepoint, else 0. */
int contains_poison (const char *s);

/* Classify `input` against the clean canonical pledge. Poison is checked
   first, so a pasted poisoned string returns V_PASTE_DETECTED, not
   V_MISMATCH. */
verdict_t classify (const char *input, const char *clean);

#endif /* PLEDGE_POISON_H */
