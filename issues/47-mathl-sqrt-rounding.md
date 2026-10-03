# Math.sqrt and MathL.sqrt are not correctly rounded

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`MathL.sqrt(2.0D0)` is 1.4142135623730949, not 1.4142135623730951, and
`Math.sqrt(1.0)` is 0.99999994. Of 3007 random doubles `MathL.sqrt` got 2029
wrong, and of 3003 random REALs `Math.sqrt` got 746 wrong; IEEE 754 requires
the square root correctly rounded.

## Reproducer

`SqrtRound.Mod`:

```oberon
MODULE SqrtRound; (* Math.sqrt and MathL.sqrt are not correctly rounded *)
IMPORT SYSTEM, Math, MathL, Out;
VAR x: REAL; y: LONGREAL; i: SYSTEM.INT32; h: SYSTEM.INT64;
BEGIN
  y := MathL.sqrt(2.0D0); h := SYSTEM.VAL(SYSTEM.INT64, y);
  Out.String("MathL.sqrt(2.0) = "); Out.Hex(h, 16); Out.String(" (expected 3FF6A09E667F3BCD)"); Out.Ln;
  x := Math.sqrt(1.0); i := SYSTEM.VAL(SYSTEM.INT32, x);
  Out.String("Math.sqrt(1.0)  = "); Out.Hex(i, 8); Out.String(" (expected 3F800000)"); Out.Ln
END SqrtRound.
```

With voc at `master`:

```
$ voc -O2 SqrtRound.Mod -m
SqrtRound.Mod  Compiling SqrtRound.  Main program.  954 chars.
$ ./SqrtRound
MathL.sqrt(2.0) = 3FF6A09E667F3BCC (expected 3FF6A09E667F3BCD)
Math.sqrt(1.0)  = 3F7FFFFF (expected 3F800000)
(exit status 0)
```

## Cause and fix

sqrt took two or three Newton steps from a linear estimate, multiplied
by sqrt(1/2) for an odd exponent, and scaled, each step rounding, so the
result was often a unit or more in the last place off. Of 3007 random
positive doubles, MathL.sqrt got 2029 wrong (MathL.sqrt(2.0D0) was
1.4142135623730949, not 1.4142135623730951), a denormal's far off, since
fraction and exponent assume a normal number; of 3003 random REALs,
Math.sqrt got 746 wrong, and Math.sqrt(1.0) was 0.99999994. IEEE 754
requires the square root correctly rounded.

MathL.sqrt now computes the integer square root of x's significand bit
by bit, as fdlibm's e_sqrt.c does, to 54 bits in 64-bit integers, and
rounds once; a denormal is normalized first, an infinity or a NaN
returned as it is. Math.sqrt rounds that LONGREAL square root (its own
copy, SqrtL, as Math cannot import MathL) to REAL, which for a square
root gives the correctly rounded REAL (53 >= 2*24 + 2). Both now agree
with the C library's sqrt and sqrtf on all of those values.

The confidence test math's MathL.sqrt(2) lines change from
1.41421356237309D+000, the digits of the old, low result, to
1.41421356237310D+000. (Applied without the Out.Real fixes before it in
this series, the Math.sqrt(1.0) lines change instead: 0.99999994 was
written 1.00000E-01 by Out.Real's exponent bug; it is now 1.0.)

With the fix:

```
$ ./SqrtRound
MathL.sqrt(2.0) = 3FF6A09E667F3BCD (expected 3FF6A09E667F3BCD)
Math.sqrt(1.0)  = 3F800000 (expected 3F800000)
(exit status 0)
```

The fix is `patches/0047-Math.sqrt-and-MathL.sqrt-correctly-rounded.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
