```
       _________________________________________________________
      |                                                         |
      |   M A I N F R A M E    4 . 2   B S D                    |
      |   csulb-mainframe.edu                                   |
      |                                                         |
      |   PRIVATE SYSTEM.   AUTHORIZED USERS ONLY.              |
      |   ALL ACTIVITY IS LOGGED AND MAY BE PROSECUTED          |
      |   UNDER 18 U.S.C. SS 1030.                              |
      |_________________________________________________________|
```

## `[--[ HOW TO LOG IN ]--]`

1. Accept the assignment from the link posted on Canvas.
2. From your assignment repo: **`<> Code` → `Codespaces` → `Create codespace on main`**.
3. Wait ~60 seconds. The terminal that appears **is** `mainframe`.
4. At the prompt, type:

   ```sh
   man mainframe
   ```

   That is your briefing.

> **When you walk away: STOP your codespace, do NOT DELETE.**
> Stop pauses (no quota burn, work preserved). Delete wipes the
> disk and any uncommitted edits. Push your work often (`git push`)
> so a lost codespace is never a lost assignment. Full guidance:
> `docs/setup.md` → "Codespaces hygiene".

## `[--[ DELIVERABLES ]--]`

| Path | What goes here |
| --- | --- |
| `student/exploit1.c` | Phase Φ exploit |
| `student/exploit2.c` | Phase Ω exploit |
| `student/WRITEUP.md` | After-action report (template provided; fill it in) |
| `student/screenshots/` | 4 PNGs: shell + flag for each phase |

Comment your code. Cite at least one source in your writeup.

## `[--[ GRADING ]--]`

| Component        | Points              | How                  |
| ---------------- | ------------------- | -------------------- |
| Phase Φ ACE      | 60                  | autograded           |
| Phase Ω ACE      | 10                  | autograded           |
| Writeup quality  | 30                  | instructor (manual)  |

Phase Ω is a stretch challenge — top students will earn it. A
solid Phase Φ exploit + a thoughtful writeup gets you to 90%.

The honor flag is a hard gate. Missing or wrong honor flag voids the autograded points.

## `[--[ PUSHING AND GRADING ]--]`

GitHub gives this course a fixed number of Actions minutes each month.
Every student's runs draw from the same pool, and one autograder run here
takes about five minutes.

- **Test in your codespace.** If your exploit prints the flag on
  `mainframe`, it works. Do not use GitHub as your test runner.
- **Push at the end of each work session**, not after every small change.
  Pushing saves your work; it does not run the exploit autograder.
- **Each repository is graded at most once an hour.** A push within an
  hour of your last graded push is saved but not graded. The check on that
  commit reads "Not graded" and says when grading resumes.
- **Submit with a tag.** Pushing a `submit/*` tag runs the full autograder
  on that commit, even inside the hour:

  ```sh
  TAG="submit/final-$(date +%Y%m%d-%H%M)"
  git tag "$TAG" && git push origin "$TAG"
  ```

  You can submit as many times as you like before the deadline. A newer
  tag cancels a run that is still going. You can also start a run by hand:
  *Actions* → *Autograde* → *Run workflow*.

The instructor also re-runs grading on your final commit after the
deadline.

## `[--[ AI ASSISTANTS ]--]`

You may use an AI assistant to learn this material: how the stack works,
what your crash in gdb means, why return-to-libc beats NX. Do not have it
write your exploits, your payload or your writeup. `AGENTS.md` at the top
of this repo asks coding assistants to tutor you rather than do the work.
Leave it in place; editing or deleting it shows up in your commit history.

## `[--[ HONOR CODE ]--]`

You may read public tutorials. **You will write your own exploit.**
Your binary is not your classmate's binary. Sharing is wasted typing.

```
[--EOF--]
```
