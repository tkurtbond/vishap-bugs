# In.LongInt reads hexadecimal digits without the H

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Given `12AB`, `In.LongInt` returns 4779 with `Done` TRUE. In Oakwood's
format hexadecimal digits need a trailing `H`; without it the input is not a
number.

## Reproducer

`InHex.Mod`:

```oberon
MODULE InHex; (* In.LongInt reads hexadecimal digits without an H *)
IMPORT In, Out;
VAR i: LONGINT;
BEGIN
  In.LongInt(i); IF In.Done THEN Out.Int(i, 0); Out.String(" read from 12AB (expected In.Done FALSE)") ELSE Out.String("In.Done FALSE") END; Out.Ln;
  In.Open;
  In.LongInt(i); Out.Int(i, 0); Out.String(" (expected 255, from 0FFH)"); Out.Ln
END InHex.
```

With voc at `master`:

```
$ voc -O2 InHex.Mod -m
InHex.Mod  Compiling InHex.  Main program.  707 chars.
$ printf '12AB 0FFH\n' | ./InHex
4779 read from 12AB (expected In.Done FALSE)
255 (expected 255, from 0FFH)
(exit status 0)
```

## Cause and fix

A digit A..F made HugeInt take the number as hexadecimal whether or not
an H followed, so 12AB was read as 4779. Oakwood's format is IntConst =
digit {digit} | digit {hexDigit} "H": digits with A..F and no H are not
a number, and Done is now FALSE for them.

With the fix:

```
$ printf '12AB 0FFH\n' | ./InHex
In.Done FALSE
255 (expected 255, from 0FFH)
(exit status 0)
```

The fix is `patches/0025-In.Int-LongInt-and-HugeInt-hexadecimal-digits-need-t.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
