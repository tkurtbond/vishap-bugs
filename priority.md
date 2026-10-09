# The issues by severity

*Prepared with the help of AI (Claude, by Anthropic). The ranking is a
judgement, made from the issues' own descriptions and reproducers.*

Most severe first. Severity here is how badly a program that meets the bug
is hurt, weighted by how easily an ordinary program meets it: silent wrong
results and memory corruption come first, then reads and writes outside an
array, then programs stopped on valid input, then wrong results that are
visible or rare, then results a few units in the last place off, then what
only the compiler rejects, then the documentation. Within a tier, the more
common case comes first.

This order says which bugs matter most, not the order in which the patches
apply: some fixes need others first (README.md, "Applying the patches"). A
fix moved up this list brings the fixes it needs along with it.

## 1. Silent wrong code, memory corruption, lost data

1. [14] - the collector can free a live object; what follows is memory
   corruption, depending on gcc's register allocation.
2. [11] - wrong data: a row of a multi-dimensional open array passed on
   reaches the callee as the wrong elements.
3. [12] - in a nested procedure, garbage lengths for the enclosing
   procedure's multi-dimensional open array: a wrong element or a trap.
4. [59] - output lost without an error: `Out`, `Files` and `Console` drop
   the rest of a partial `write` (pipes, signals).
5. [50] - corrupts files: a CR LF text opened and closed with `Texts` gets
   twice as many lines.
6. [07] - wrong arithmetic: 64-bit `DIV`/`MOD` near `MIN`/`MAX` (`-OC`).
7. [10] - wrong arithmetic: `ABS` of a 64-bit argument with side effects is
   cut to 32 bits.
8. [58] - `localtime` reads past a 4-byte `LONGINT` (`Files.GetDate`,
   `-O2`): undefined behaviour; a NIL trap on FreeBSD and OpenBSD.
9. [30] - numbers written ten times too small: `Out.Real`/`LongReal` miss
   the exponent's carry (`1.0E37` is written `1.0E+36`).
10. [38] - wrong sign: the cosine from `sincos` is never negative, and so
    `MathL.tan` has the wrong sign on half its domain.
11. [28] - wrong value: `StrToReal`/`StrToLongReal` read `2.5E+2` as 2.5.
12. [03] - constants change value in the generated C; a tiny one becomes 0
    (`MathL.power(0, 3)` is about 2.5D-5).
13. [61] - `PID` wraps under `-O2`, and two programs can make the same
    temporary file names and clobber each other's files.
14. [09] - wrong characters: `CAP` changes characters that are not
    lower-case letters.
15. [06] - wrong values: `SHORT` of a `LONGREAL` is not rounded inside an
    expression.
16. [68] - wrong data: a fixed-array value parameter given a shorter or an
    open array holds what lies past its actual (an open one is cut, with
    no 0X and no length test).
17. [67] - `ethStrings.RealToStr` writes nonsense on little-endian machines.

## 2. Reading or writing outside an array

Each is an index trap with voc's default `-x`, and memory corruption
without it.

18. [23] - `Files.ReadString`/`ReadLine` take the length from the file's
    contents, so a file can overrun the program's array.
19. [65] - `Texts.Scan` on a numeral of 32 digits or more, also taken from
    the input.
20. [21] - `Strings.Extract` into a small destination.
21. [20] - `Strings.Append`/`Insert` leave no 0X, so whatever reads the
    result next runs off its end.
22. [57] - `Strings.Cap` of a string that fills its array.
23. [52] - `Texts.Close` of a file name of 60 characters or more.
24. [22] - `Strings.Pos` with a negative start.

## 3. Programs, or the compiler, stopped on valid input

25. [49] - storing a text loaded from a file: NIL access.
26. [51] - `Texts.Save`/`Copy` of an element that is not copied: NIL access.
27. [15] - `Files` after a change of directory: `Halt(99)` at a later
    `Register`.
28. [17] - `Files.Rename` of an open file: `Halt(99)` later.
29. [46] - `Texts.Scan` of a large exponent: `HALT(40)` (a small one is read
    as 0).
30. [48] - sin, cos and tan of a large argument are 0 (`Math.err` is set).
31. [45] - `Texts.WriteRealFix` drops decimals, and traps above 9 digits.
32. [27] - `In.Name` halts: not implemented.
33. [08] - the compiler dies of SIGFPE on `MIN(HUGEINT) DIV (-1)`.
34. [01] - the compiler halts on an integral `LONGREAL` literal or a
    constant `ENTIER` of 2^31 or more (`-OC`).

## 4. Wrong results that show, or need unusual input

35. [18] - `Strings.Insert` past the end does nothing.
36. [19] - `Strings.Replace` deletes too much.
37. [26] - `In.Real`/`LongReal` swallow the rest of the line.
38. [25] - `In.LongInt` takes hexadecimal digits without the `H`.
39. [16] - `Files.Delete` of an open file reports failure but deletes it.
40. [60] - `Platform.Delay` returns early on a signal.
41. [62] - `Modules.ThisMod`/`ThisCommand` miss long names.
42. [64] - `Oberon.Log` echoes deleted and changed text.
43. [63] - `Oberon.Par` cuts arguments to 255 characters.
44. [33] - `VT100` cuts a count of 10 or more to its first digit.
45. [35] - `VT100.SetAttr` cuts its argument, leaving a sequence open.
46. [34] - `VT100.DSR` always sends 6.
47. [43] - `Texts` writes an infinity as NaN.
48. [31] - `Out.LongReal` writes a subnormal number as 0.
49. [44] - `Texts` writes a subnormal number as 0.
50. [56] - `arcsinh`/`arccosh` of a large argument.
51. [55] - `exp` is 0 where the result is subnormal.
52. [54] - `fraction`, `ulp` and `scale` of a subnormal number.
53. [42] - `exponent` of a subnormal number.
54. [39] - `succ`/`pred` are not the neighbouring numbers.
55. [41] - `MathL.small` is 0.
56. [53] - `Texts.WriteInt` of `MIN(SYSTEM.INT64)` ignores the width.

## 5. A few units in the last place

57. [66] - `Texts.Scan` reals (a third of `REAL`s wrong).
58. [32] - `Out.LongReal` digits (most do not read back).
59. [29] - `StrToReal`/`StrToLongReal`.
60. [02] - real literals.
61. [47] - `sqrt`.
62. [36] - `Reals.TenL` (and 10 for a negative exponent).
63. [05] - `MAX(LONGREAL)`, and the folded `MAX(REAL)`.

## 6. Rejected at compile time

64. [13] - recursion inside a `WITH` on the procedure's own parameter: a
    false error, or C that gcc rejects. The workaround is easy.
65. [24] - a `HUGEINT` variable cannot be passed to `In.HugeInt`.
66. [04] - real literals near the top of the range are "number too large".
67. [40] - real literals below the smallest normal number are "number too
    large".

## 7. Documentation

68. [37] - `Features.md` says `SET` has 64 bits under `-OC`.

[01]: issues/01-entier-64.md
[02]: issues/02-real-literal-rounding.md
[03]: issues/03-real-constants-exact.md
[04]: issues/04-real-literal-largest-exponent.md
[05]: issues/05-max-real-exact.md
[06]: issues/06-short-longreal-cast.md
[07]: issues/07-div-mod-overflow.md
[08]: issues/08-const-div-minus-one.md
[09]: issues/09-cap-letters-only.md
[10]: issues/10-abs-side-effects-64.md
[11]: issues/11-open-array-row-stride.md
[12]: issues/12-nested-open-array-lengths.md
[13]: issues/13-with-self-recursion.md
[14]: issues/14-gc-callee-saved-registers.md
[15]: issues/15-files-absolute-names.md
[16]: issues/16-files-delete-open.md
[17]: issues/17-files-rename-open.md
[18]: issues/18-strings-insert-past-end.md
[19]: issues/19-strings-replace-count.md
[20]: issues/20-strings-append-insert-0x.md
[21]: issues/21-strings-extract-small-dest.md
[22]: issues/22-strings-pos-negative.md
[23]: issues/23-files-readstring-bounds.md
[24]: issues/24-hugeint-is-int64.md
[25]: issues/25-in-hex-needs-h.md
[26]: issues/26-in-real-one-number.md
[27]: issues/27-in-name.md
[28]: issues/28-strtoreal-exponent-plus.md
[29]: issues/29-strtoreal-rounding.md
[30]: issues/30-out-real-exponent-carry.md
[31]: issues/31-out-subnormal.md
[32]: issues/32-out-real-correct-rounding.md
[33]: issues/33-vt100-counts.md
[34]: issues/34-vt100-dsr.md
[35]: issues/35-vt100-setattr.md
[36]: issues/36-reals-tenl-exact.md
[37]: issues/37-features-set-size.md
[38]: issues/38-math-sincos-cos.md
[39]: issues/39-math-succ-pred.md
[40]: issues/40-real-literal-smallest.md
[41]: issues/41-mathl-small.md
[42]: issues/42-math-exponent-denormal.md
[43]: issues/43-texts-infinity.md
[44]: issues/44-texts-subnormal.md
[45]: issues/45-texts-writerealfix.md
[46]: issues/46-texts-scan-range.md
[47]: issues/47-mathl-sqrt-rounding.md
[48]: issues/48-math-sin-cos-large.md
[49]: issues/49-texts-load-fonts.md
[50]: issues/50-texts-store-crlf.md
[51]: issues/51-texts-copy-elem.md
[52]: issues/52-texts-close-long-name.md
[53]: issues/53-texts-writeint-min.md
[54]: issues/54-math-fraction-denormal.md
[55]: issues/55-math-exp-denormal.md
[56]: issues/56-math-arcsinh-large.md
[57]: issues/57-strings-cap-bound.md
[58]: issues/58-platform-mtime-o2.md
[59]: issues/59-platform-write-partial.md
[60]: issues/60-platform-delay-signal.md
[61]: issues/61-platform-pid.md
[62]: issues/62-modules-long-names.md
[63]: issues/63-oberon-long-params.md
[64]: issues/64-oberon-log-echo.md
[65]: issues/65-texts-scan-long-number.md
[66]: issues/66-texts-scan-rounding.md
[67]: issues/67-ethreals-word-offsets.md
[68]: issues/68-array-value-parameter.md
