# Math.exponent and MathL.exponent of a denormal number are wrong

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Every denormal gets the exponent -127 (`MathL`: -1023): `Math.exponent` of
2^-149 is -127, not -149.

## Reproducer

`ExponentDenormal.Mod`:

```oberon
MODULE ExponentDenormal; (* Math.exponent of a denormal is expoMin - 1 *)
IMPORT SYSTEM, Math, MathL, Out;
VAR i: SYSTEM.INT32; h: HUGEINT; x: REAL; y: LONGREAL;
BEGIN
  i := 1; x := SYSTEM.VAL(REAL, i);          (* 2^-149, the smallest REAL denormal *)
  Out.String("Math.exponent(2^-149)   = "); Out.Int(Math.exponent(x), 0); Out.String(" (expected -149)"); Out.Ln;
  i := 400000H; x := SYSTEM.VAL(REAL, i);    (* 2^-127 *)
  Out.String("Math.exponent(2^-127)   = "); Out.Int(Math.exponent(x), 0); Out.String(" (expected -127)"); Out.Ln;
  i := 200000H; x := SYSTEM.VAL(REAL, i);    (* 2^-128 *)
  Out.String("Math.exponent(2^-128)   = "); Out.Int(Math.exponent(x), 0); Out.String(" (expected -128)"); Out.Ln;
  h := 1; y := SYSTEM.VAL(LONGREAL, h);      (* 2^-1074 *)
  Out.String("MathL.exponent(2^-1074) = "); Out.Int(MathL.exponent(y), 0); Out.String(" (expected -1074)"); Out.Ln
END ExponentDenormal.
```

With voc at `master`:

```
$ voc -O2 ExponentDenormal.Mod -m
ExponentDenormal.Mod  Compiling ExponentDenormal.  Main program.  1525 chars.
$ ./ExponentDenormal
Math.exponent(2^-149)   = -127 (expected -149)
Math.exponent(2^-127)   = -127 (expected -127)
Math.exponent(2^-128)   = -127 (expected -128)
MathL.exponent(2^-1074) = -1023 (expected -1074)
(exit status 0)
```

## Cause and fix

exponent read the biased exponent field and subtracted the bias, but a
denormal's field is 0 whatever its value, so every denormal had the
exponent -127 (MathL: -1023): Math.exponent of 2^-149 was -127, not
-149. A denormal is now first scaled into the normal range by a power of
two (2^25; MathL 2^60), which is exact, and the power subtracted again.
The result is below expoMin, as it must be for x = fraction(x) *
2^exponent(x) to hold. (fraction and scale still assume a normal
number.)

With the fix:

```
$ ./ExponentDenormal
Math.exponent(2^-149)   = -149 (expected -149)
Math.exponent(2^-127)   = -127 (expected -127)
Math.exponent(2^-128)   = -128 (expected -128)
MathL.exponent(2^-1074) = -1074 (expected -1074)
(exit status 0)
```

The fix is `patches/0042-Math.exponent-and-MathL.exponent-of-a-denormal-numbe.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
