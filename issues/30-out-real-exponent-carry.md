# Out.Real and Out.LongReal write a wrong exponent when rounding carries

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

When rounding the digits carries into a new leading digit, the exponent is
not incremented: `1.0E37` is written `1.0E+36`, `1.0D300` `1.0D+299`, and the
double just below 1.0 `1.0D-001`.

## Reproducer

`OutExponent.Mod`:

```oberon
MODULE OutExponent; (* Out.Real and Out.LongReal: the exponent misses a carry from rounding *)
IMPORT SYSTEM, Out;
VAR r: REAL; d: LONGREAL; bits: SYSTEM.INT64;
BEGIN
  r := 1.0E37; Out.Real(r, 0); Out.String(" (expected 1.0E+37)"); Out.Ln;
  d := 1.0D300; Out.LongReal(d, 0); Out.String(" (expected 1.0D+300)"); Out.Ln;
  bits := 3FEFFFFFFFFFFFFFH; SYSTEM.GET(SYSTEM.ADR(bits), d);  (* the double below 1.0 *)
  Out.LongReal(d, 0); Out.String(" (expected 1.0D+000: 0.99999999999999989 rounded)"); Out.Ln
END OutExponent.
```

With voc at `master`:

```
$ voc -O2 OutExponent.Mod -m
OutExponent.Mod  Compiling OutExponent.  Main program.  904 chars.
$ ./OutExponent
1.0E+36 (expected 1.0E+37)
1.0D+299 (expected 1.0D+300)
1.0D-001 (expected 1.0D+000: 0.99999999999999989 rounded)
(exit status 0)
```

## Cause and fix

RealP wrote the exponent's digits before rounding the mantissa, so when
rounding carried (9.99..9 up to 10.0, and the mantissa was divided by
ten and e incremented) the increment was lost: 1.0E37 was written
1.0E+36, 1.0D300 1.0D+299, and the double below 1.0 1.0D-001. The math
confidence test expected Math.sqrt(1) to be written 1.00000E-01, and
MathL.cos(0), 0.99999999999999989 with "Write real constants to C
exactly" applied, 1.00000000000000D-001; both are now written as
1.0.

With the fix:

```
$ ./OutExponent
1.0E+37 (expected 1.0E+37)
1.0D+300 (expected 1.0D+300)
1.0D+000 (expected 1.0D+000: 0.99999999999999989 rounded)
(exit status 0)
```

The fix is `patches/0030-Out.Real-and-LongReal-write-the-exponent-after-round.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
