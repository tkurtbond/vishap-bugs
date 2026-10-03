# VT100 cuts a count of 10 or more to its first digit

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`VT100.CUU(12)` sends `ESC[1A`, moving up one line, not twelve: the count is
converted into an `ARRAY 2 OF CHAR`. Two-argument sequences cut a count at 4
digits (`CUP(12345, 67)` sends `ESC[1234;67H`).

## Reproducer

`VT100Count.Mod`:

```oberon
MODULE VT100Count; (* a count of 10 or more is cut to its first digit *)
IMPORT VT100, Out;
BEGIN
  VT100.CUU(12); Out.String(" (expected ESC[12A)"); Out.Ln;
  VT100.CUP(12345, 67); Out.String(" (expected ESC[12345;67H)"); Out.Ln
END VT100Count.
```

With voc at `master`:

```
$ voc -O2 VT100Count.Mod -m
VT100Count.Mod  Compiling VT100Count.  Main program.  538 chars.
$ ./VT100Count
[1A (expected ESC[12A)
[1234;67H (expected ESC[12345;67H)
(exit status 0)
```

## Cause and fix

EscSeq and EscSeqSwapped converted their count into an ARRAY 2 OF CHAR,
which holds one digit, so a count of 10 or more was cut to its first
digit: CUU(12) sent ESC[1A and moved up one line. EscSeq2's ARRAY 5
cut a count of five digits or more (CUP(12345, 67) sent ESC[1234;67H).
The buffers now hold any INTEGER under either size model.

With the fix:

```
$ ./VT100Count
[12A (expected ESC[12A)
[12345;67H (expected ESC[12345;67H)
(exit status 0)
```

The fix is `patches/0033-VT100-counts-of-any-size.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
