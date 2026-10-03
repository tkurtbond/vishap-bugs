# MAX(LONGREAL) is not the largest LONGREAL, and a folded MAX(REAL) is not the stored one

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`MAX(LONGREAL)` (and `MathL.large`) is 7FEFFFFFCCCCCCD3, about
1.7976929634D308, not 7FEFFFFFFFFFFFFF. `MAX(REAL)` folded by the compiler
is 3.40282346D38, slightly below the largest REAL, so it is not equal to
`MAX(REAL)` stored in a `REAL` variable.

## Reproducer

`MaxReal.Mod`:

```oberon
MODULE MaxReal; (* MAX(LONGREAL) is not the largest LONGREAL, MAX(REAL) not the largest REAL *)
IMPORT SYSTEM, Out;
VAR d: LONGREAL; r: REAL; bits: SYSTEM.INT64; bits32: SYSTEM.INT32;
BEGIN
  d := MAX(LONGREAL); SYSTEM.GET(SYSTEM.ADR(d), bits);
  Out.String("MAX(LONGREAL): "); Out.Hex(bits, 16);
  Out.String(", expected 7FEFFFFFFFFFFFFF"); Out.Ln;
  r := MAX(REAL); SYSTEM.GET(SYSTEM.ADR(r), bits32);
  Out.String("MAX(REAL):     "); Out.Hex(bits32, 8);
  Out.String(", expected 7F7FFFFF"); Out.Ln;
  IF MAX(REAL) = r THEN Out.String("ok") ELSE Out.String("MAX(REAL) folded # MAX(REAL) stored") END; Out.Ln
END MaxReal.
```

With voc at `master`:

```
$ voc -O2 MaxReal.Mod -m
MaxReal.Mod  Compiling MaxReal.  Main program.  1030 chars.
$ ./MaxReal
MAX(LONGREAL): 7FEFFFFFCCCCCCD3, expected 7FEFFFFFFFFFFFFF
MAX(REAL):     7F7FFFFF, expected 7F7FFFFF
MAX(REAL) folded # MAX(REAL) stored
(exit status 0)
```

## Cause and fix

OPM.MaxLReal was 1.7976931348623157D307 * 9.999999, 7FEFFFFFCCCCCCD3,
about 1.7976929634D308, so MAX(LONGREAL) and MathL.large were below the
largest LONGREAL. OPM.MaxReal was 3.40282346D38, which is below the
largest REAL (3.4028234663852886D38) when folded: a folded MAX(REAL) was
not equal to one stored in a REAL. Both are now set from their IEEE 754
bit patterns. The math confidence test's expected output changes with
MathL.large.

With the fix:

```
$ ./MaxReal
MAX(LONGREAL): 7FEFFFFFFFFFFFFF, expected 7FEFFFFFFFFFFFFF
MAX(REAL):     7F7FFFFF, expected 7F7FFFFF
ok
(exit status 0)
```

The fix is `patches/0005-Make-MAX-REAL-and-MAX-LONGREAL-the-largest-REAL-and-.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0003 (Real constants lose digits in the generated C).

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
