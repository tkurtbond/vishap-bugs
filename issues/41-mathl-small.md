# MathL.small is 0

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`MathL.small`, meant to be the smallest normal `LONGREAL`, 2^-1022, is 0.0 in
the compiled library.

## Reproducer

`MathLSmall.Mod`:

```oberon
MODULE MathLSmall; (* MathL.small is not the smallest normal LONGREAL, 2^-1022 *)
IMPORT SYSTEM, MathL, Out;
VAR h: HUGEINT; x: LONGREAL;
BEGIN
  x := MathL.small; h := SYSTEM.VAL(HUGEINT, x);
  Out.String("MathL.small = "); Out.Hex(h, 16); Out.String(" (expected 0010000000000000)"); Out.Ln
END MathLSmall.
```

With voc at `master`:

```
$ voc -O2 MathLSmall.Mod -m
MathLSmall.Mod  Compiling MathLSmall.  Main program.  656 chars.
$ ./MathLSmall
MathL.small = 0000000000000000 (expected 0010000000000000)
(exit status 0)
```

## Cause and fix

small was 2.2250738585072014/9.9999999999999981D307, a workaround for
the scanner refusing 2.2250738585072014D-308, and the C written for it
was 0, so MathL.small was 0.0. With the constants written exactly the
quotient is 000FFFFFFAAD8B05, a denormal, still not 2^-1022. small is
now the literal 2.2250738585072014D-308, which is 2^-1022 exactly.

With the fix:

```
$ ./MathLSmall
MathL.small = 0010000000000000 (expected 0010000000000000)
(exit status 0)
```

The fix is `patches/0041-MathL.small-the-smallest-normal-LONGREAL.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0040 (Real literals below the smallest normal number are "number too large"); patch 0003 (Real constants lose digits in the generated C).

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
