# Bugs in Vishap Oberon (voc), with reproducers and fixes

*Prepared with the help of AI (Claude, by Anthropic). Every reproducer was
run, and the output in each issue is copied from those runs.*

These are bugs found in [Vishap Oberon](https://github.com/vishapoberon/compiler)
v2.1.0 while it was used to bootstrap, and to cross-check, the
[Peaseblossom](https://github.com/tkurtbond/peaseblossom) Oberon-2 compiler.
Each one is written up as a GitHub issue, one bug to an issue, with a
reproducer, and has a fix of its own, one commit to a patch.

Nothing here has been submitted to voc's repository.

## Layout

- `issues/NN-name.md`: the issue text. The first line is the title, and the
  rest is the body.
- `reproducers/NN-name/*.Mod`: the reproducer modules, the same as in the
  issue text. Compile one with `voc -O2 File.Mod -m` (or `-OC`, where the
  issue says so) and run `./File`.
- `patches/00NN-*.patch`: the fix, `git format-patch` of one commit.
- `differences.md`: where voc does otherwise than one might expect, or
  than a comment in its source says, without that being a bug: wrong
  claims (in comments or elsewhere) and design choices, each with what
  was found. Nothing there has a patch.
- `priority.md`: the 68 issues ranked by severity, most severe first.
- `notes/NN-name/`: longer accounts of two of the bugs, 13 and 14.
- `tools/`: what produced and checked all of the above, described in
  "Reproducing the results" below.

## Applying the patches

The patches form one series, made against voc's `master` at commit
`9701249a` ("adding ulm unix file and terminal streams.", 2026-09-25). In
order, they apply with

    git checkout -b fixes 9701249a
    git am /path/to/vishap-bugs/patches/*.patch

Every commit of the series builds with `make all`, and `make all` passes the
confidence tests at each commit.

Most patches are independent of one another, but some are not:

- **Needs**: the patch needs the ones listed applied first, either because
  it relies on what they do, or because it changes lines that they change
  in the same function. The "Needs" column below lists them, and so does
  each issue text.
- **After**: 03 changes `OPM.WriteReal`, which 01 also changes, 14 changes
  `SYSTEM.h` next to 09's `CAP`, 20 changes `Strings.Insert`, which 18
  also changes, 54 changes lines of `Math` next to 48's, 61 changes
  `Files.GetTempName`, which 15 also changes, and 65 changes
  `Texts.Scan` where 46 does. Each of these is made to apply after the
  earlier patch, though it does not need it.
- **Confidence tests**: 03, 05, 30, 32, 38, 45 and 47 change the expected
  output of the confidence tests `math`, `out` or `texts`. The expected
  output each one gives is for the series up to it. Applied out of order,
  the expected files conflict or no longer match; regenerating them (run
  the test, then copy `result` to `expected`) is all such a patch needs.
  The commit messages of 30, 32 and 47 say which lines change in the
  series and why.

The chains are:

- 02 ← 03 ← 05, and 02 ← 04 ← 40 ← 41, where 41 also needs 03 (and 04's
  `1.7976931348623157D308` needs 03 to reach the C code without becoming
  infinity).
- 30, 31 ← 32 (Out.Real and LongReal).
- 15 ← 17 (Files).
- 28 ← 29 (Strings.StrToReal).
- 42 ← 54 ← 55 (Math and MathL on denormal numbers).
- 65 ← 66 (Texts.Scan).

## Reproducing the results

Build voc twice with `make all`, at `master` and with the series applied
(`git am`), and use each one's `install` directory (`bin/`, `lib/`, ...):

- `tools/runall.sh LABEL VOCDIR OUTDIR` compiles and runs every reproducer
  listed in `tools/manifest` (issue, size model, modules, standard input,
  setup, modules compiled first, a command to run in place of the
  program) and writes the transcripts. The issue texts use those labelled
  `master` and `new`. Issue 58 does not show on Linux; its FreeBSD
  transcripts, from voc built there at `master` and with the series, are
  in `tools/issues.py`.
- `tools/gen.py VOCCLONE OUTDIR` writes `issues/*.md` and this README from
  `tools/issues.py` (each issue's title and summary, and the table of
  dependencies), `tools/README.head.md`, the reproducers, the transcripts,
  and the commit messages of the branch `series` in VOCCLONE. Write
  `patches/` with `git -C VOCCLONE format-patch -o patches master..series`
  first.
- `tools/each-commit.sh VOCCLONE` builds every commit of the series with
  `make all` and reports whether its confidence tests pass.
- `tools/checks/run.sh VOCDIR` makes the counts quoted in patches 0032,
  0047, 0048 and 0066: Out.LongReal's digits for 2000 random doubles,
  Math.sqrt and MathL.sqrt for 3003 REALs and 3007 doubles, sin, cos and
  tan for 407 arguments from 9100 to 4.2E307, compared with the C
  library's, and Texts.Scan for 2000 REAL and 1000 LONGREAL numerals,
  compared with the correctly rounded values.
  `tools/checks/literals.sh VOCDIR SRCDIR` makes those in patch 0002, for
  the real literals in voc's `src/`.

## The issues

