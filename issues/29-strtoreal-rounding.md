# Strings.StrToReal and StrToLongReal are not correctly rounded

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Strings.StrToLongReal("0.3", d)` does not give the double nearest 0.3, nor
`"1.0E23"` the double nearest 10^23: the value is built digit by digit with
rounding at every step.

## Reproducer

`StrToReal.Mod`:

```oberon
MODULE StrToReal; (* Strings.StrToLongReal and StrToReal do not round correctly *)
IMPORT Strings, Out;
VAR d, ten: LONGREAL; r, tenR: REAL;
BEGIN (* the comparison values are made by one correctly rounded operation on exact values *)
  ten := 10.0D0; tenR := 10.0E0;
  Strings.StrToLongReal("0.3", d);
  IF d = 3.0D0 / ten THEN Out.String("ok") ELSE Out.String("StrToLongReal(0.3) is not the double nearest 0.3") END; Out.Ln;
  Strings.StrToLongReal("1.0E23", d);
  IF d = 1.0D22 * ten THEN Out.String("ok") ELSE Out.String("StrToLongReal(1.0E23) is not the double nearest 10^23") END; Out.Ln;
  Strings.StrToReal("0.7", r);
  IF r = 7.0E0 / tenR THEN Out.String("ok") ELSE Out.String("StrToReal(0.7) is not the REAL nearest 0.7") END; Out.Ln
END StrToReal.
```

With voc at `master`:

```
$ voc -O2 StrToReal.Mod -m
StrToReal.Mod  Compiling StrToReal.  Main program.  1242 chars.
$ ./StrToReal
StrToLongReal(0.3) is not the double nearest 0.3
StrToLongReal(1.0E23) is not the double nearest 10^23
ok
(exit status 0)
```

## Cause and fix

They built the value digit by digit (y * 10 + d, then g / 10 for each
fraction digit) and scaled it by Reals.Ten, each step rounding, so 0.3
was not the double nearest 0.3, nor 1.0E23 the one nearest 10^23. The
numeral is now handed to C's strtod (strtof for REAL), which rounds
correctly; a D exponent is written E for it.

With the fix:

```
$ ./StrToReal
ok
ok
ok
(exit status 0)
```

The fix is `patches/0029-Strings.StrToReal-and-StrToLongReal-round-correctly.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0028 (Strings.StrToReal and StrToLongReal ignore an exponent with a + sign).

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
