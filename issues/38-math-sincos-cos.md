# Math.sincos and MathL.sincos give a cosine that is never negative

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`sincos` computes the cosine as `sqrt(1 - sin(x)^2)`, so for x in (pi/2,
3pi/2) it has the wrong sign: `Math.sincos(2.0)` gives cos 0.416, where cos(2)
is -0.416. `MathL.tan` is computed from `sincos`, so it has the wrong sign
there too, and near a pole it is far off: `MathL.tan` of the `LONGREAL`
nearest pi/2 is 2.02E7, not 1.633E16.

## Reproducer

`SinCos.Mod`:

```oberon
MODULE SinCos; (* Math.sincos and MathL.sincos give a cosine that is never negative *)
IMPORT Math, MathL, Out;
VAR s, c: REAL; sl, cl: LONGREAL;
BEGIN
  Math.sincos(2.0, s, c);
  Out.String("Math.sincos(2.0):   cos "); Out.Real(c, 14); Out.String(" (expected "); Out.Real(Math.cos(2.0), 14); Out.String(")"); Out.Ln;
  MathL.sincos(2.0D0, sl, cl);
  Out.String("MathL.sincos(2.0):  cos "); Out.LongReal(cl, 23); Out.String(" (expected "); Out.LongReal(MathL.cos(2.0D0), 23); Out.String(")"); Out.Ln
END SinCos.
```

With voc at `master`:

```
$ voc -O2 SinCos.Mod -m
SinCos.Mod  Compiling SinCos.  Main program.  974 chars.
$ ./SinCos
Math.sincos(2.0):   cos 4.16146755E-01 (expected -4.1614681E-01)
MathL.sincos(2.0):  cos 4.1614683654714336D-001 (expected -4.161468365471423D-001)
(exit status 0)
```

## Cause and fix

sincos gave the cosine as sqrt(1 - sin(x)^2), which is never negative,
so for x in (pi/2, 3pi/2) (mod 2pi) it had the wrong sign:
Math.sincos(2.0) gave cos 0.416, where cos(2) is -0.416. Near the
cosine's zeros it also lost accuracy, since 1 - sin^2 cancels there.
sincos now calls cos.

MathL.tan is sin/cos from sincos, so it had the wrong sign wherever the
cosine is negative, and lost accuracy near pi/2: tan(1.5707963267949),
just past pi/2, was 2.02E7, where it is -2.86E14, and tan(3.14159265358979)
was positive. The confidence test math's expected output changes there.

With the fix:

```
$ ./SinCos
Math.sincos(2.0):   cos -4.1614681E-01 (expected -4.1614681E-01)
MathL.sincos(2.0):  cos -4.161468365471424D-001 (expected -4.161468365471424D-001)
(exit status 0)
```

The fix is `patches/0038-Math.sincos-and-MathL.sincos-the-cosine-s-sign.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
