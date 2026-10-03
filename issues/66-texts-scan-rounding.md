# Texts.Scan does not read real numbers correctly rounded

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Texts.Scan` computes a real number's value digit by digit in floating
point, so it is often a unit or more in the last place off: `1.06E7` is
read as 10599999.0, and `0.3D0` is not the `LONGREAL` nearest 0.3. Of
2000 random `REAL` numerals 636 are read wrong, and of 1000 `LONGREAL`
ones 869.

## Reproducer

`TextsScanRound.Mod`:

```oberon
MODULE TextsScanRound; (* Texts.Scan of real numbers: are they correctly rounded? *)
IMPORT SYSTEM, Texts, Out;
VAR T: Texts.Text; W: Texts.Writer; S: Texts.Scanner; i: SYSTEM.INT32; h: SYSTEM.INT64;
PROCEDURE Next(expected: ARRAY OF CHAR);
BEGIN
  Texts.Scan(S);
  IF S.class = Texts.Real THEN i := SYSTEM.VAL(SYSTEM.INT32, S.x); Out.Hex(i, 8)
  ELSE h := SYSTEM.VAL(SYSTEM.INT64, S.y); Out.Hex(h, 16)
  END;
  Out.String(" (expected "); Out.String(expected); Out.Char(")"); Out.Ln
END Next;
BEGIN
  Texts.OpenWriter(W); Texts.WriteString(W, "1.06E7 0.3D0 6.02214076D23");
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenScanner(S, T, 0);
  Next("4B21BE40, 10600000.0");
  Next("3FD3333333333333");
  Next("44DFE185CA57C517")
END TextsScanRound.
```

With voc at `master`:

```
$ voc -O2 TextsScanRound.Mod -m
TextsScanRound.Mod  Compiling TextsScanRound.  Main program.  1875 chars.
$ ./TextsScanRound
4B21BE3F (expected 4B21BE40, 10600000.0)
3FD3333333333334 (expected 3FD3333333333333)
44DFE185CA57C515 (expected 44DFE185CA57C517)
(exit status 0)
```

## Cause and fix

Scan computed a real number's value digit by digit in floating point,
dividing by 10 for each decimal and scaling by a power of ten, each step
rounding, so the result was often a unit or more in the last place off,
where IEEE 754 and every C library read a decimal numeral correctly
rounded. Of 2000 random REAL numerals Scan read 636 wrong, and of 1000
LONGREAL ones 666 (869 at voc's master), up to 4 units in the last place
off (8 at master): 1.06E7 was 10599999.0, not 10600000.0.

Scan now gives the digits it read, and the exponent, to the C library's
strtof (for a REAL) or strtod (for a LONGREAL), which round correctly;
a number out of range is still 0 or an infinity.

With the fix:

```
$ ./TextsScanRound
4B21BE40 (expected 4B21BE40, 10600000.0)
3FD3333333333333 (expected 3FD3333333333333)
44DFE185CA57C517 (expected 44DFE185CA57C517)
(exit status 0)
```

The fix is `patches/0066-Texts.Scan-real-numbers-correctly-rounded.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0065 (Texts.Scan traps on a number of 32 digits or more).

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
