# Texts.Scan stops the program with HALT(40) on a large exponent

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Texts.Scan` of a real number whose exponent is above 38 (E) or 308 (D)
stops the program with `HALT(40)`, even when the number is in range
(`0.001D310` is 1.0D307); a number whose negative exponent is beyond those is
read as 0 even when it is in range (`1000.0D-310`).

## Reproducer

`TextsScan.Mod`:

```oberon
MODULE TextsScan; (* Texts.Scan: a number with a large exponent stops the program (HALT(40)) *)
IMPORT Texts, Out;
VAR W: Texts.Writer; T: Texts.Text; S: Texts.Scanner;
PROCEDURE Try(text, expected: ARRAY OF CHAR);
BEGIN
  NEW(T); Texts.Open(T, ""); Texts.WriteString(W, text); Texts.Append(T, W.buf);
  Texts.OpenScanner(S, T, 0); Texts.Scan(S);
  Out.String(text); Out.String(": ");
  IF S.class = 4 THEN Out.Real(S.x, 15) ELSIF S.class = 5 THEN Out.LongReal(S.y, 24) ELSE Out.String("class "); Out.Int(S.class, 0) END;
  Out.String(" (expected "); Out.String(expected); Out.String(")"); Out.Ln
END Try;
BEGIN
  Texts.OpenWriter(W);
  Try("0.001D310", "about 1.0D+307");
  Try("1000.0D-310", "about 1.0D-307");
  Try("1.0D309", "Infinity");
  Try("1.0E39", "Infinity");
  Try("0.0D400", "0.0")
END TextsScan.
```

With voc at `master`:

```
$ voc -O2 TextsScan.Mod -m
TextsScan.Mod  Compiling TextsScan.  Main program.  2014 chars.
$ ./TextsScan
Terminated by Halt(40). 
(exit status 40)
```

## Cause and fix

Scan stopped the program with HALT(40) on a real number whose exponent
was above 38 (E) or 308 (D), even one in range, such as 0.001D310
(1.0D307), and read one whose negative exponent was beyond those as 0,
even 1000.0D-310 (1.0D-307). Beyond 10^38 or 10^308 it now scales in two
steps, so such a number is read; one out of range becomes an infinity
(or 0), as a too-large or too-small result of arithmetic does.

With the fix:

```
$ ./TextsScan
0.001D310:  9.9999999999999999D+306 (expected about 1.0D+307)
1000.0D-310:  9.9999999999999991D-308 (expected about 1.0D-307)
1.0D309:                 Infinity (expected Infinity)
1.0E39:        Infinity (expected Infinity)
0.0D400:  0.0000000000000000D+000 (expected 0.0)
(exit status 0)
```

The fix is `patches/0046-Texts.Scan-a-number-with-a-large-exponent-is-read-no.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
