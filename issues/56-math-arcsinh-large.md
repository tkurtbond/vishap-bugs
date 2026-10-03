# Math and MathL: arcsinh and arccosh of a large argument are wrong

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

For an argument above about 9.2E18 (`REAL`) or 6.7E153 (`LONGREAL`),
`arcsinh` and `arccosh` report HypInvTrigClipped and return the same
value, ln(sqrt(MAX)), whatever the argument. Both functions are finite for
every finite argument, and there they are ln(2x).

## Reproducer

`ArcsinhLarge.Mod`:

```oberon
MODULE ArcsinhLarge; (* arcsinh and arccosh of a large argument *)
IMPORT Math, MathL, Out;
VAR x: REAL; y: LONGREAL;
BEGIN
  x := 1.0E10; x := x * x; Math.ClearError;
  Out.Real(Math.arcsinh(x), 16); Out.String(" error "); Out.Int(Math.err, 0);
  Out.String(" (expected about 4.6745E+01, error 0)"); Out.Ln;
  Math.ClearError;
  Out.Real(Math.arccosh(x), 16); Out.String(" error "); Out.Int(Math.err, 0);
  Out.String(" (expected about 4.6745E+01, error 0)"); Out.Ln;
  y := 1.0D100; y := y * y; Math.ClearError;
  Out.LongReal(MathL.arcsinh(y), 24); Out.String(" error "); Out.Int(Math.err, 0);
  Out.String(" (expected 4.6121016577936911D+002, error 0)"); Out.Ln
END ArcsinhLarge.
```

With voc at `master`:

```
$ voc -O2 ArcsinhLarge.Mod -m
ArcsinhLarge.Mod  Compiling ArcsinhLarge.  Main program.  1268 chars.
$ ./ArcsinhLarge
  4.43614197E+01 error 8 (expected about 4.6745E+01, error 0)
  4.43614197E+01 error 8 (expected about 4.6745E+01, error 0)
 3.5489135639900824D+002 error 8 (expected 4.6121016577936911D+002, error 0)
(exit status 0)
```

## Cause and fix

arcsinh and arccosh reported HypInvTrigClipped and returned
ln(SqrtInfinity) for an argument above SqrtInfinity/2 (about 9.2E18 for
REAL, 6.7E153 for LONGREAL), where x * x might overflow:
Math.arcsinh(1.0E20) was 44.36, not 46.74, and MathL.arcsinh(1.0D200) was
354.9, not 461.2. Both functions are defined, and finite, for every
finite argument.

There x * x + 1 and x * x - 1 equal x * x to every place, so the result
is ln(2x), which is now returned as ln(x) + ln(2), with no error.

With the fix:

```
$ ./ArcsinhLarge
  4.67448463E+01 error 0 (expected about 4.6745E+01, error 0)
  4.67448463E+01 error 0 (expected about 4.6745E+01, error 0)
 4.6121016577936911D+002 error 0 (expected 4.6121016577936911D+002, error 0)
(exit status 0)
```

The fix is `patches/0056-Math-and-MathL-arcsinh-and-arccosh-of-a-large-argume.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
