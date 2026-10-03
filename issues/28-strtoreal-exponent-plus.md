# Strings.StrToReal and StrToLongReal ignore an exponent with a + sign

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Strings.StrToLongReal("2.5E+2", d)` gives 2.5, not 250: only a `-` is accepted
after the `E`.

## Reproducer

`StrToRealPlus.Mod`:

```oberon
MODULE StrToRealPlus; (* Strings.StrToLongReal and StrToReal ignore an exponent with a "+" *)
IMPORT Strings, Out;
VAR d: LONGREAL; r: REAL;
BEGIN
  Strings.StrToLongReal("2.5E+2", d); Out.LongReal(d, 0); Out.String(" (expected 250)"); Out.Ln;
  Strings.StrToReal("2.5E+2", r); Out.Real(r, 0); Out.String(" (expected 250)"); Out.Ln
END StrToRealPlus.
```

With voc at `master`:

```
$ voc -O2 StrToRealPlus.Mod -m
StrToRealPlus.Mod  Compiling StrToRealPlus.  Main program.  740 chars.
$ ./StrToRealPlus
2.5D+000 (expected 250)
2.5E+00 (expected 250)
(exit status 0)
```

## Cause and fix

Only a - was taken after the E or D; with a +, no digit followed and the
exponent was 0, so "2.5E+2" was 2.5.

With the fix:

```
$ ./StrToRealPlus
2.5D+002 (expected 250)
2.5E+02 (expected 250)
(exit status 0)
```

The fix is `patches/0028-Strings.StrToReal-and-StrToLongReal-read-an-exponent.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
