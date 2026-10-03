# Real constants lose digits in the generated C

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

A real constant is written into the C file with 15 or 16 significant
digits, so the C compiler often reads back a different value: a folded
`1.0D0 / 3.0D0` is not equal to the same division done at run time. A very
small constant can come out as 0 (MathL's `miny`, so `MathL.power(0.0D0,
3.0D0)` is about 2.5D-5, not 0). `Math`'s sin and tan, which reduce their
argument by multiples of the constants `pi` and `piByTwo`, so of what is
left of them in C, are hundreds of units in the last place off, and near
a multiple of pi/2 up to a million: `Math.tan(1.5707964)` is 3.0E14, not
-2.29E7.

## Reproducer

`RealConstants.Mod`:

```oberon
MODULE RealConstants; (* real constants lose digits in the generated C *)
IMPORT Out;
VAR d, e: LONGREAL; r, s: REAL;
BEGIN
  d := 1.0D0 / 3.0D0;                  (* folded by voc, written to the C file *)
  e := 1.0D0; e := e / 3.0D0;          (* computed at run time *)
  IF d = e THEN Out.String("ok") ELSE Out.String("folded 1.0D0 / 3.0D0 # 1.0D0 / 3.0D0 at run time") END; Out.Ln;
  r := 1.0E0 / 3.0E0;
  s := 1.0E0; s := s / 3.0E0;
  IF r = s THEN Out.String("ok") ELSE Out.String("folded 1.0E0 / 3.0E0 # 1.0E0 / 3.0E0 at run time") END; Out.Ln
END RealConstants.
```

With voc at `master`:

```
$ voc -O2 RealConstants.Mod -m
RealConstants.Mod  Compiling RealConstants.  Main program.  1033 chars.
$ ./RealConstants
folded 1.0D0 / 3.0D0 # 1.0D0 / 3.0D0 at run time
ok
(exit status 0)
```

## Cause and fix

OPM.WriteReal wrote a non-integral constant with Texts.WriteLongReal, 16
or 15 significant digits, so the C compiler read back a different value
for many: a folded 1.0D0 / 3.0D0 was not equal to the same division done
at run time. It now writes a C99 hexadecimal constant, [-]0x1.hhh..p+e,
which is exact. Microsoft C, which may not read them, keeps the decimal.

A small constant could come out as 0: MathL's miny (1/MAX(LONGREAL)) was
written as 0, so MathL.power(0.0D0, 3.0D0), which tests ABS(base) < miny,
went on with a zero base and returned about 2.5D-5, not 0; it is now 0.

The confidence tests' expected output changes with it: out's
1.2345678987654321D3 is now the double nearest (40934A45874103E1, was
...D8), and math's MathL results with it (sin(pi) is 1.22464023514027D-16,
cos(pi/2) 6.12320117570134D-17, arctan(1) 7.85398163397448D-1).

Math reduces the argument of sin, cos and tan as LONG(x) - LONG(xn) * pi,
meaning pi in LONGREAL precision, but pi and piByTwo are REAL constants:
the C used to carry them as decimal numerals with more digits than a
REAL has, and now carries the REAL values exactly, which made
Math.sin(3.14159274), the REAL nearest pi, -0.0 instead of -8.74228E-08
and Math.tan of the REAL nearest pi/2 -Infinity. The reductions now use
LONGREAL constants piL and piByTwoL, and give those values correctly.

With the fix:

```
$ ./RealConstants
ok
ok
(exit status 0)
```

The fix is `patches/0003-Write-real-constants-to-C-exactly-as-hexadecimal-flo.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0002 (Real literals are not correctly rounded).
It changes lines that patch 0001 (Integral LONGREAL literals >= 2^31 and constant ENTIER >= 2^31 halt the compiler under -OC) also changes, and is made to apply after it.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
