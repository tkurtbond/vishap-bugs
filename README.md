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
  `SYSTEM.h` next to 09's `CAP`, and 20 changes `Strings.Insert`, which 18
  also changes. Each of these is made to apply after the earlier patch,
  though it does not need it.
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

## Reproducing the results

Build voc twice with `make all`, at `master` and with the series applied
(`git am`), and use each one's `install` directory (`bin/`, `lib/`, ...):

- `tools/runall.sh LABEL VOCDIR OUTDIR` compiles and runs every reproducer
  listed in `tools/manifest` (issue, size model, modules, standard input,
  setup) and writes the transcripts. The issue texts use those labelled
  `master` and `new`.
- `tools/gen.py VOCCLONE OUTDIR` writes `issues/*.md` and this README from
  `tools/issues.py` (each issue's title and summary, and the table of
  dependencies), `tools/README.head.md`, the reproducers, the transcripts,
  and the commit messages of the branch `series` in VOCCLONE. Write
  `patches/` with `git -C VOCCLONE format-patch -o patches master..series`
  first.
- `tools/each-commit.sh VOCCLONE` builds every commit of the series with
  `make all` and reports whether its confidence tests pass.
- `tools/checks/run.sh VOCDIR` makes the counts quoted in patches 0032,
  0047 and 0048: Out.LongReal's digits for 2000 random doubles, Math.sqrt
  and MathL.sqrt for 3003 REALs and 3007 doubles, and sin, cos and tan for
  407 arguments from 9100 to 4.2E307, compared with the C library's.
  `tools/checks/literals.sh VOCDIR SRCDIR` makes those in patch 0002, for
  the real literals in voc's `src/`.

## The issues

| # | Issue | Patch | Needs |
|---|-------|-------|-------|
| 01 | [Integral LONGREAL literals >= 2^31 and constant ENTIER >= 2^31 halt the compiler under -OC](issues/01-entier-64.md) | [0001](patches/0001-Take-ENTIER-of-constants-2-31-in-64-bits-in-the-comp.patch) |  |
| 02 | [Real literals are not correctly rounded](issues/02-real-literal-rounding.md) | [0002](patches/0002-Round-real-literals-correctly-let-C-s-strtod-and-str.patch) |  |
| 03 | [Real constants lose digits in the generated C](issues/03-real-constants-exact.md) | [0003](patches/0003-Write-real-constants-to-C-exactly-as-hexadecimal-flo.patch) | 02 (after 01) |
| 04 | [REAL literals of 1.0E38 or more and LONGREAL literals of 1.0D308 or more are "number too large"](issues/04-real-literal-largest-exponent.md) | [0004](patches/0004-Accept-real-literals-from-1.0E38-to-MAX-REAL-1.0D308.patch) | 02 |
| 05 | [MAX(LONGREAL) is not the largest LONGREAL, and a folded MAX(REAL) is not the stored one](issues/05-max-real-exact.md) | [0005](patches/0005-Make-MAX-REAL-and-MAX-LONGREAL-the-largest-REAL-and-.patch) | 03 |
| 06 | [SHORT of a LONGREAL is not rounded to REAL inside an expression](issues/06-short-longreal-cast.md) | [0006](patches/0006-Round-SHORT-of-a-LONGREAL-to-REAL-where-it-is-used-n.patch) |  |
| 07 | [DIV and MOD give wrong results for a 64-bit dividend near MIN or MAX, and a constant product of -2^63 is rejected](issues/07-div-mod-overflow.md) | [0007](patches/0007-SYSTEM_DIV-SYSTEM_MOD-no-overflow-for-a-dividend-nea.patch) |  |
| 08 | [Constant MIN(HUGEINT) DIV (-1) crashes the compiler with SIGFPE](issues/08-const-div-minus-one.md) | [0008](patches/0008-Constant-MIN-SYSTEM.INT64-DIV-1-is-an-error-not-a-co.patch) |  |
| 09 | [CAP changes characters that are not lower-case letters](issues/09-cap-letters-only.md) | [0009](patches/0009-CAP-changes-only-lower-case-letters.patch) |  |
| 10 | [ABS of a 64-bit argument with side effects is cut to 32 bits](issues/10-abs-side-effects-64.md) | [0010](patches/0010-ABS-of-a-64-bit-argument-with-side-effects-is-not-cu.patch) |  |
| 11 | [A row of a multi-dimensional open array passed as an open array ignores the row stride](issues/11-open-array-row-stride.md) | [0011](patches/0011-Index-a-row-of-a-multi-dimensional-open-array-with-t.patch) |  |
| 12 | [A nested procedure gets garbage inner lengths for its parent's multi-dimensional open array](issues/12-nested-open-array-lengths.md) | [0012](patches/0012-Copy-every-length-of-an-open-array-parameter-into-a-.patch) |  |
| 13 | [A procedure calling itself inside a WITH on its own parameter: false err 113, or C that does not compile](issues/13-with-self-recursion.md) | [0013](patches/0013-Check-and-pass-a-recursive-call-s-arguments-against-.patch) |  |
| 14 | [The collector frees an object referenced only from a callee-saved register](issues/14-gc-callee-saved-registers.md) | [0014](patches/0014-Heap.GC-store-the-callee-saved-registers-before-scan.patch) | (after 09) |
| 15 | [Files keeps relative names and later renames by them from another directory: Halt(99)](issues/15-files-absolute-names.md) | [0015](patches/0015-Files-keep-each-file-s-name-as-a-whole-path.patch) |  |
| 16 | [Files.Delete of a file the program has open reports failure but deletes it](issues/16-files-delete-open.md) | [0016](patches/0016-Files.Delete-of-an-open-file-reports-success.patch) |  |
| 17 | [Files.Rename of an open file leaves the open File with the old name: Halt(99) later](issues/17-files-rename-open.md) | [0017](patches/0017-Files.Rename-gives-an-open-File-of-the-renamed-file-.patch) | 15 |
| 18 | [Strings.Insert at a position past the end does nothing](issues/18-strings-insert-past-end.md) | [0018](patches/0018-Strings.Insert-at-a-position-past-the-end-appends.patch) |  |
| 19 | [Strings.Replace deletes pos + Length(source) characters](issues/19-strings-replace-count.md) | [0019](patches/0019-Strings.Replace-deletes-Length-source-characters.patch) |  |
| 20 | [Strings.Append and Insert leave no 0X when the result is too long](issues/20-strings-append-insert-0x.md) | [0020](patches/0020-Strings.Append-and-Insert-cut-a-result-too-long-for-.patch) | (after 18) |
| 21 | [Strings.Extract into a small dest writes past its end](issues/21-strings-extract-small-dest.md) | [0021](patches/0021-Strings.Extract-cuts-a-part-too-long-for-dest-to-end.patch) |  |
| 22 | [Strings.Pos with a negative start is an index trap](issues/22-strings-pos-negative.md) | [0022](patches/0022-Strings.Pos-with-a-negative-start-searches-from-0.patch) |  |
| 23 | [Files.ReadString and Files.ReadLine write past the end of the array](issues/23-files-readstring-bounds.md) | [0023](patches/0023-Files.ReadString-and-ReadLine-stop-at-the-end-of-the.patch) |  |
| 24 | [A HUGEINT variable cannot be passed to In.HugeInt](issues/24-hugeint-is-int64.md) | [0024](patches/0024-Make-HUGEINT-another-name-for-SYSTEM.INT64.patch) |  |
| 25 | [In.LongInt reads hexadecimal digits without the H](issues/25-in-hex-needs-h.md) | [0025](patches/0025-In.Int-LongInt-and-HugeInt-hexadecimal-digits-need-t.patch) |  |
| 26 | [In.Real and In.LongReal read the rest of the line, cut at 15 characters](issues/26-in-real-one-number.md) | [0026](patches/0026-In.Real-and-LongReal-read-one-number-and-set-Done.patch) |  |
| 27 | [In.Name is not implemented](issues/27-in-name.md) | [0027](patches/0027-Implement-In.Name.patch) |  |
| 28 | [Strings.StrToReal and StrToLongReal ignore an exponent with a + sign](issues/28-strtoreal-exponent-plus.md) | [0028](patches/0028-Strings.StrToReal-and-StrToLongReal-read-an-exponent.patch) |  |
| 29 | [Strings.StrToReal and StrToLongReal are not correctly rounded](issues/29-strtoreal-rounding.md) | [0029](patches/0029-Strings.StrToReal-and-StrToLongReal-round-correctly.patch) | 28 |
| 30 | [Out.Real and Out.LongReal write a wrong exponent when rounding carries](issues/30-out-real-exponent-carry.md) | [0030](patches/0030-Out.Real-and-LongReal-write-the-exponent-after-round.patch) |  |
| 31 | [Out.LongReal writes a subnormal number as 0](issues/31-out-subnormal.md) | [0031](patches/0031-Out.LongReal-writes-a-subnormal-number-not-0.patch) |  |
| 32 | [Out.LongReal does not write correctly rounded digits](issues/32-out-real-correct-rounding.md) | [0032](patches/0032-Out.Real-and-LongReal-correctly-rounded-digits-from-.patch) | 30, 31 |
| 33 | [VT100 cuts a count of 10 or more to its first digit](issues/33-vt100-counts.md) | [0033](patches/0033-VT100-counts-of-any-size.patch) |  |
| 34 | [VT100.DSR sends 6 whatever its argument](issues/34-vt100-dsr.md) | [0034](patches/0034-VT100.DSR-sends-its-argument.patch) |  |
| 35 | [VT100.SetAttr cuts its argument at 13 characters](issues/35-vt100-setattr.md) | [0035](patches/0035-VT100.SetAttr-writes-all-of-its-argument.patch) |  |
| 36 | [Reals.TenL is not correctly rounded](issues/36-reals-tenl-exact.md) | [0036](patches/0036-Reals.TenL-correctly-rounded.patch) |  |
| 37 | [Features.md says SET has 64 bits under -OC](issues/37-features-set-size.md) | [0037](patches/0037-Features.md-SET-has-32-bits-under-OC-too.patch) |  |
| 38 | [Math.sincos and MathL.sincos give a cosine that is never negative](issues/38-math-sincos-cos.md) | [0038](patches/0038-Math.sincos-and-MathL.sincos-the-cosine-s-sign.patch) |  |
| 39 | [Math.succ and Math.pred do not give the neighbouring numbers](issues/39-math-succ-pred.md) | [0039](patches/0039-Math-and-MathL-succ-and-pred-give-the-neighbouring-n.patch) |  |
| 40 | [Real literals below the smallest normal number are "number too large"](issues/40-real-literal-smallest.md) | [0040](patches/0040-Accept-real-literals-below-the-smallest-normal-numbe.patch) | 02, 04 |
| 41 | [MathL.small is 0](issues/41-mathl-small.md) | [0041](patches/0041-MathL.small-the-smallest-normal-LONGREAL.patch) | 40, 03 |
| 42 | [Math.exponent and MathL.exponent of a denormal number are wrong](issues/42-math-exponent-denormal.md) | [0042](patches/0042-Math.exponent-and-MathL.exponent-of-a-denormal-numbe.patch) |  |
| 43 | [Texts writes an infinity as NaN](issues/43-texts-infinity.md) | [0043](patches/0043-Texts-an-infinity-is-written-as-Infinity-not-NaN.patch) |  |
| 44 | [Texts writes a subnormal number as 0](issues/44-texts-subnormal.md) | [0044](patches/0044-Texts-a-subnormal-number-is-written-with-its-digits-.patch) |  |
| 45 | [Texts.WriteRealFix drops decimals and traps on numbers with more than 9 digits before the point](issues/45-texts-writerealfix.md) | [0045](patches/0045-Texts.WriteRealFix-the-decimals-asked-for-and-number.patch) |  |
| 46 | [Texts.Scan stops the program with HALT(40) on a large exponent](issues/46-texts-scan-range.md) | [0046](patches/0046-Texts.Scan-a-number-with-a-large-exponent-is-read-no.patch) |  |
| 47 | [Math.sqrt and MathL.sqrt are not correctly rounded](issues/47-mathl-sqrt-rounding.md) | [0047](patches/0047-Math.sqrt-and-MathL.sqrt-correctly-rounded.patch) |  |
| 48 | [Math and MathL: sin, cos and tan of a large argument are 0](issues/48-math-sin-cos-large.md) | [0048](patches/0048-Math-and-MathL-sin-cos-and-tan-of-a-large-argument.patch) |  |
