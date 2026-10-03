# Texts.Scan traps on a number of 32 digits or more

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Texts.Scan` keeps a number's digits in an `ARRAY 32 OF CHAR` with no
bound, so a number of 32 digits or more, its integer part and decimals
together, stops the program with an index out of range: pi written to 36
decimal places is enough.

## Reproducer

`TextsScanLong.Mod`:

```oberon
MODULE TextsScanLong; (* Texts.Scan of a number of 32 digits or more *)
IMPORT Texts, Out;
VAR T: Texts.Text; W: Texts.Writer; S: Texts.Scanner; i: INTEGER;
BEGIN
  Texts.OpenWriter(W);
  Texts.WriteString(W, "3.14159265358979323846264338327950288 ");
  FOR i := 1 TO 300 DO Texts.Write(W, "1") END;     (* an integer of 300 digits *)
  Texts.WriteString(W, " next");
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenScanner(S, T, 0);
  Texts.Scan(S); Out.String("class "); Out.Int(S.class, 0);
  Out.String(" (expected 4, a REAL)"); Out.Ln;
  Texts.Scan(S); Out.String("class "); Out.Int(S.class, 0);
  Out.String(" (expected 0, Inval: too long for any integer)"); Out.Ln;
  Texts.Scan(S); Out.String("class "); Out.Int(S.class, 0); Out.Char(" "); Out.String(S.s);
  Out.String(" (expected 1 next)"); Out.Ln
END TextsScanLong.
```

With voc at `master`:

```
$ voc -O2 TextsScanLong.Mod -m
TextsScanLong.Mod  Compiling TextsScanLong.  Main program.  1920 chars.
$ ./TextsScanLong
Terminated by Halt(-2). Index out of range.
(exit status 254)
```

## Cause and fix

Scan kept a number's digits in an ARRAY 32 OF CHAR with no bound, so a
number of 32 digits or more, its integer part and decimals together,
stopped the program with an index out of range:
3.14159265358979323846264338327950288 did.

Scan now keeps up to 256 digits, in an array of that many with INTEGER
indices (they were SHORTINTs), and only counts those beyond. A real
number's integer digits beyond them scale it by a power of ten, and its
decimals beyond them are dropped; an integer with more digits than that,
more than any integer type holds, is Inval. negE, which a real number
without a scale factor read uninitialized, starts FALSE.

With the fix:

```
$ ./TextsScanLong
class 4 (expected 4, a REAL)
class 0 (expected 0, Inval: too long for any integer)
class 1 next (expected 1 next)
(exit status 0)
```

The fix is `patches/0065-Texts.Scan-numbers-of-32-digits-or-more.patch`, a `git format-patch` of one commit.

It changes lines that patch 0046 (Texts.Scan stops the program with HALT(40) on a large exponent) also changes, and is made to apply after it.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
