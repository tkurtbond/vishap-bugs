# Real literals are not correctly rounded

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

The scanner converts decimal real literals with a sequence of rounded
operations, so many literals become a neighbouring double: `1.1D3` is
1100.0000000000002, `123.456D0` is 123.45600000000002, `1.0D23` is
1.0000000000000001D23. Constant folding and constant comparisons see these
values.

## Reproducer

`LiteralRounding.Mod`:

```oberon
MODULE LiteralRounding; (* the scanner does not round decimal real literals correctly *)
IMPORT Out;
CONST (* compared by the compiler, with the values its scanner made *)
  a = 1.1D3 = 1100;                        (* 1.1D3 is 1100.0000000000002 *)
  b = 123.456D0 * 1000 = 123456;           (* 123.456D0 is 123.45600000000002 *)
  c = 1.0D23 = 1.0D22 * 10;                (* 1.0D23 is 1.0000000000000001D23 *)
BEGIN
  IF a THEN Out.String("ok") ELSE Out.String("1.1D3 # 1100") END; Out.Ln;
  IF b THEN Out.String("ok") ELSE Out.String("123.456D0 * 1000 # 123456") END; Out.Ln;
  IF c THEN Out.String("ok") ELSE Out.String("1.0D23 # 1.0D22 * 10") END; Out.Ln
END LiteralRounding.
```

With voc at `master`:

```
$ voc -O2 LiteralRounding.Mod -m
LiteralRounding.Mod  Compiling LiteralRounding.  Main program.  512 chars.
$ ./LiteralRounding
1.1D3 # 1100
123.456D0 * 1000 # 123456
1.0D23 # 1.0D22 * 10
(exit status 0)
```

## Cause and fix

OPS.Number built 0.ddd by successive divisions by 10 and scaled it by a
power of ten made by repeated squaring, each step rounding, so many
literals were a few units in the last place off: 1.1D3 became
1100.0000000000002, 123.456D0 123.45600000000002, 1.0D23
1.0000000000000001D23. Constant folding and comparison see these values.
The scanner now hands the literal's digits and exponent to strtod
(LONGREAL) or strtof (REAL), which round correctly. The digit buffer
grows from 24 to 64 digits, so a long constant such as MathL.pi is not
cut short.

Of the 236 distinct real literals in voc's own source, a program
compiled by voc at master gets 68 as a value other than the nearest REAL
or LONGREAL (some through this, some through the C written for them,
"Write real constants to C exactly"), and 3 do not compile under -OC
(1.0D10, 1.0D16 and 1.0E10: "Take ENTIER of constants >= 2^31 in 64
bits"). With those two and this one applied, all 236 are right.

With the fix:

```
$ ./LiteralRounding
ok
ok
ok
(exit status 0)
```

The fix is `patches/0002-Round-real-literals-correctly-let-C-s-strtod-and-str.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
