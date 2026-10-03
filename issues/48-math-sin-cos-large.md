# Math and MathL: sin, cos and tan of a large argument are 0

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Math.sin` and `Math.cos` return 0 and set `Math.err` to LossOfAccuracy for
an argument of 9099 or more, `Math.tan` above 6434, and `MathL.sin` and
`MathL.cos` (and so `MathL.tan`) for one of 210828714 or more:
`Math.sin(10000.0)` is 0, not -0.3056. Every finite real has a sine.

## Reproducer

`LargeTrig.Mod`:

```oberon
MODULE LargeTrig; (* Math and MathL: sin, cos (and Math.tan) of a large argument are 0, with LossOfAccuracy *)
IMPORT Math, MathL, Out;
VAR x: REAL; y: LONGREAL;
BEGIN
  x := 10000.0; Math.ClearError;
  Out.String("Math.sin(10000.0)  = "); Out.Real(Math.sin(x), 14); Out.String(", err "); Out.Int(Math.err, 0);
  Out.String(" (expected -3.05614E-01, err 0)"); Out.Ln;
  x := 1.0E5; x := x * x; x := x * x * x; Math.ClearError;   (* 1.0E30, made at run time *)
  Out.String("Math.tan(1.0E30)   = "); Out.Real(Math.tan(x), 14); Out.String(", err "); Out.Int(Math.err, 0);
  Out.String(" (expected about 1.2936, err 0)"); Out.Ln;
  y := 1.0D5; y := y * y; Math.ClearError;           (* 1.0D10 *)
  Out.String("MathL.sin(1.0D10)  = "); Out.LongReal(MathL.sin(y), 24); Out.String(", err "); Out.Int(Math.err, 0);
  Out.String(" (expected -4.875060251...D-001, err 0)"); Out.Ln;
  y := y * y; y := y * 100.0D0; Math.ClearError;     (* 1.0D22 *)
  Out.String("MathL.cos(1.0D22)  = "); Out.LongReal(MathL.cos(y), 24); Out.String(", err "); Out.Int(Math.err, 0);
  Out.String(" (expected 5.232147853951389D-001, err 0)"); Out.Ln
END LargeTrig.
```

With voc at `master`:

```
$ voc -O2 LargeTrig.Mod -m
LargeTrig.Mod  Compiling LargeTrig.  Main program.  1750 chars.
$ ./LargeTrig
Math.sin(10000.0)  = 0.00000000E+00, err 10 (expected -3.05614E-01, err 0)
Math.tan(1.0E30)   = 0.00000000E+00, err 10 (expected about 1.2936, err 0)
MathL.sin(1.0D10)  =  0.0000000000000000D+000, err 10 (expected -4.875060251...D-001, err 0)
MathL.cos(1.0D22)  =  0.0000000000000000D+000, err 10 (expected 5.232147853951389D-001, err 0)
(exit status 0)
```

## Cause and fix

Math.sin and Math.cos gave 0 and reported LossOfAccuracy for an argument
of 9099 or more, Math.tan for one above 6434, and MathL.sin and MathL.cos
(and so MathL.tan) for one of 210828714 or more: Math.sin(10000.0) was 0,
not -0.3056. Every finite REAL and LONGREAL has a sine; Cody and Waite's
reduction, which SinCos uses, only loses its accuracy beyond those
limits.

Beyond them the argument is now reduced as Payne and Hanek do (and
fdlibm's __kernel_rem_pio2): x * 2/pi modulo 4, computed in 64-bit
integers from the 192 bits of 2/pi that matter at x's exponent (a table
of 2/pi's bits, 24 to an element), gives the quadrant and the remainder
r, |r| <= pi/4, whose sine or cosine the existing code computes. An
infinity or a NaN still gives LossOfAccuracy and 0.

Checked against the C library on 407 arguments from 1E4 to 1E308: Math's
results are within 3 units in the last place of sinf, cosf and tanf;
MathL's within 13 of sin and cos, which is the error of MathL's own
sin and cos on |r| <= pi/4. (Below the limits nothing changes; there the
existing reduction's error grows with x, to thousands of units in the
last place near the limit.)

With the fix:

```
$ ./LargeTrig
Math.sin(10000.0)  = -3.0561438E-01, err 0 (expected -3.05614E-01, err 0)
Math.tan(1.0E30)   = 1.29358590E+00, err 0 (expected about 1.2936, err 0)
MathL.sin(1.0D10)  = -4.8750602508751062D-001, err 0 (expected -4.875060251...D-001, err 0)
MathL.cos(1.0D22)  =  5.2321478539513899D-001, err 0 (expected 5.232147853951389D-001, err 0)
(exit status 0)
```

The fix is `patches/0048-Math-and-MathL-sin-cos-and-tan-of-a-large-argument.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
