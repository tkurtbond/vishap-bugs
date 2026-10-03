# Math and MathL: fraction, ulp and scale are wrong for denormal numbers

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`fraction`, `ulp` and `scale` take every number to be normal.
`Math.fraction` of a denormal number is wrong, `Math.scale` gives the
smallest normal number for any result below the normal range, and `ulp`
of a denormal number is the smallest normal number or 0. The same holds
for `MathL`.

## Reproducer

`FractionDenormal.Mod`:

```oberon
MODULE FractionDenormal; (* fraction, ulp and scale of denormal numbers *)
IMPORT SYSTEM, Math, MathL, Out;
VAR x: REAL; i: SYSTEM.INT32; a: LONGREAL; h: SYSTEM.INT64;
PROCEDURE R(t: ARRAY OF CHAR; v: REAL; e: ARRAY OF CHAR);
BEGIN i := SYSTEM.VAL(SYSTEM.INT32, v); Out.String(t); Out.Hex(i, 8);
  Out.String(" (expected "); Out.String(e); Out.Char(")"); Out.Ln
END R;
PROCEDURE L(t: ARRAY OF CHAR; v: LONGREAL; e: ARRAY OF CHAR);
BEGIN h := SYSTEM.VAL(SYSTEM.INT64, v); Out.String(t); Out.Hex(h, 16);
  Out.String(" (expected "); Out.String(e); Out.Char(")"); Out.Ln
END L;
BEGIN
  i := 3; x := SYSTEM.VAL(REAL, i);                  (* 3 * 2^-149 *)
  R("Math.fraction(3*2^-149)    ", Math.fraction(x), "3FC00000, 1.5");
  R("Math.ulp(3*2^-149)         ", Math.ulp(x), "00000001, 2^-149");
  R("Math.scale(1.0, -140)      ", Math.scale(1.0, -140), "00000200, 2^-140");
  R("Math.scale(3*2^-149, 10)   ", Math.scale(x, 10), "00000C00, 3*2^-139");
  h := 3; a := SYSTEM.VAL(LONGREAL, h);              (* 3 * 2^-1074 *)
  L("MathL.fraction(3*2^-1074)  ", MathL.fraction(a), "3FF8000000000000, 1.5");
  L("MathL.ulp(3*2^-1074)       ", MathL.ulp(a), "0000000000000001, 2^-1074");
  L("MathL.scale(1.0, -1060)    ", MathL.scale(1.0D0, -1060), "0000000000004000, 2^-1060")
END FractionDenormal.
```

With voc at `master`:

```
$ voc -O2 FractionDenormal.Mod -m
FractionDenormal.Mod  Compiling FractionDenormal.  Main program.  2528 chars.
$ ./FractionDenormal
Math.fraction(3*2^-149)    3F800003 (expected 3FC00000, 1.5)
Math.ulp(3*2^-149)         00800000 (expected 00000001, 2^-149)
Math.scale(1.0, -140)      00800000 (expected 00000200, 2^-140)
Math.scale(3*2^-149, 10)   05000003 (expected 00000C00, 3*2^-139)
MathL.fraction(3*2^-1074)  3FF0000000000003 (expected 3FF8000000000000, 1.5)
MathL.ulp(3*2^-1074)       0000000000000000 (expected 0000000000000001, 2^-1074)
MathL.scale(1.0, -1060)    0000000000000000 (expected 0000000000004000, 2^-1060)
(exit status 0)
```

## Cause and fix

fraction, ulp and scale took every number to be normal. fraction of a
denormal number put its bits, which have no hidden bit, under a normal
exponent: Math.fraction(3 * 2^-149) was 1.0000004, not 1.5. scale gave
small (2^-126, 2^-1022) for any result below the normal range, where
the result is a denormal number or 0: Math.scale(1.0, -140) was 2^-126,
not 2^-140; and it kept the bits of a denormal x under the new exponent,
so Math.scale(3 * 2^-149, 10) was (1 + 3 * 2^-23) * 2^-117, not
3 * 2^-139. ulp of a denormal number, whose last place is that of the
smallest denormal, was small or less (MathL.ulp(3 * 2^-1074) was 0 at
voc's master).

fraction now scales a denormal number by an exact power of two to a
normal one first, as exponent does. scale builds the result from
fraction(x), and makes one below the normal range, rounded once, by
scaling to 2^places times it and multiplying by 2^-places, exactly; one
below half the smallest denormal is 0. ulp is at least the smallest
denormal.

With the fix:

```
$ ./FractionDenormal
Math.fraction(3*2^-149)    3FC00000 (expected 3FC00000, 1.5)
Math.ulp(3*2^-149)         00000001 (expected 00000001, 2^-149)
Math.scale(1.0, -140)      00000200 (expected 00000200, 2^-140)
Math.scale(3*2^-149, 10)   00000C00 (expected 00000C00, 3*2^-139)
MathL.fraction(3*2^-1074)  3FF8000000000000 (expected 3FF8000000000000, 1.5)
MathL.ulp(3*2^-1074)       0000000000000001 (expected 0000000000000001, 2^-1074)
MathL.scale(1.0, -1060)    0000000000004000 (expected 0000000000004000, 2^-1060)
(exit status 0)
```

The fix is `patches/0054-Math-and-MathL-fraction-ulp-and-scale-of-denormal-nu.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0042 (Math.exponent and MathL.exponent of a denormal number are wrong).
It changes lines that patch 0048 (Math and MathL: sin, cos and tan of a large argument are 0) also changes, and is made to apply after it.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
