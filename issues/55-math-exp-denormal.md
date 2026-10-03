# Math.exp and MathL.exp give 0 where the result is a denormal number

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Math.exp(x)` is 0, and sets `Math.err` to Underflow, for any `x` below
about -88.7, though `exp(x)` is a denormal `REAL` down to about -103.3.
`MathL.exp(x)` is 0 below about -709.8, though the result is a denormal
`LONGREAL` down to about -744.4.

## Reproducer

`ExpDenormal.Mod`:

```oberon
MODULE ExpDenormal; (* exp of an argument whose result is a denormal number *)
IMPORT Math, MathL, Out;
BEGIN
  Math.ClearError;
  Out.Real(Math.exp(-90.0), 16); Out.String(" error "); Out.Int(Math.err, 0);
  Out.String(" (expected about 8.19E-40, error 0)"); Out.Ln;
  Math.ClearError;
  Out.LongReal(MathL.exp(-720.0D0), 24); Out.String(" error "); Out.Int(Math.err, 0);
  Out.String(" (expected about 2.03E-313, error 0)"); Out.Ln
END ExpDenormal.
```

With voc at `master`:

```
$ voc -O2 ExpDenormal.Mod -m
ExpDenormal.Mod  Compiling ExpDenormal.  Main program.  805 chars.
$ ./ExpDenormal
  0.00000000E+00 error 11 (expected about 8.19E-40, error 0)
 0.0000000000000000D+000 error 0 (expected about 2.03E-313, error 0)
(exit status 0)
```

## Cause and fix

exp returned 0 for every x below ln(1/MAX), about -88.7 for REAL and
-709.8 for LONGREAL, though exp(x) is a denormal number down to about
-103.3 and -744.4: Math.exp(-90.0) was 0, with Math.err set to
Underflow, not 8.2E-40, and MathL.exp(-720.0D0) was 0, not 2.0E-313.

The limit is now the logarithm of half the smallest denormal number,
below which exp(x) rounds to 0, and exp's result is scaled into the
denormal range by scale.

With the fix:

```
$ ./ExpDenormal
  8.19400869E-40 error 0 (expected about 8.19E-40, error 0)
 2.0322308024677665D-313 error 0 (expected about 2.03E-313, error 0)
(exit status 0)
```

The fix is `patches/0055-Math.exp-and-MathL.exp-results-in-the-denormal-range.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0054 (Math and MathL: fraction, ulp and scale are wrong for denormal numbers).

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
