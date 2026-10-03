# Math.succ and Math.pred do not give the neighbouring numbers

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

For a negative number `succ` moves down and `pred` up (`Math.succ(-1.0)` is
-1.0000001); at a power of two `pred` skips a number (`Math.pred(1.0)` is 1 -
2^-23, not 1 - 2^-24); `succ(0.0)` is 2^-23 rather than the smallest
denormal. The same holds for `MathL`.

## Reproducer

`SuccPred.Mod`:

```oberon
MODULE SuccPred; (* Math.succ/pred: not the neighbouring numbers *)
IMPORT SYSTEM, Math, MathL, Out;
PROCEDURE R(t: ARRAY OF CHAR; x: REAL; expected: ARRAY OF CHAR);
  VAR i: SYSTEM.INT32;
BEGIN i := SYSTEM.VAL(SYSTEM.INT32, x);
  Out.String(t); Out.Hex(i, 8); Out.String(" (expected "); Out.String(expected); Out.String(")"); Out.Ln
END R;
PROCEDURE L(t: ARRAY OF CHAR; x: LONGREAL; expected: ARRAY OF CHAR);
  VAR h: HUGEINT;
BEGIN h := SYSTEM.VAL(HUGEINT, x);
  Out.String(t); Out.Hex(h, 16); Out.String(" (expected "); Out.String(expected); Out.String(")"); Out.Ln
END L;
BEGIN
  R("Math.succ(-1.0)  = ", Math.succ(-1.0), "BF7FFFFF, -0.99999994");
  R("Math.pred(-1.0)  = ", Math.pred(-1.0), "BF800001, -1.0000001");
  R("Math.pred(1.0)   = ", Math.pred(1.0), "3F7FFFFF, 0.99999994");
  R("Math.succ(0.0)   = ", Math.succ(0.0), "00000001");
  L("MathL.succ(-1.0) = ", MathL.succ(-1.0D0), "BFEFFFFFFFFFFFFF");
  L("MathL.pred(1.0)  = ", MathL.pred(1.0D0), "3FEFFFFFFFFFFFFF")
END SuccPred.
```

With voc at `master`:

```
$ voc -O2 SuccPred.Mod -m
SuccPred.Mod  Compiling SuccPred.  Main program.  1989 chars.
$ ./SuccPred
Math.succ(-1.0)  = BF800001 (expected BF7FFFFF, -0.99999994)
Math.pred(-1.0)  = BF7FFFFE (expected BF800001, -1.0000001)
Math.pred(1.0)   = 3F7FFFFE (expected 3F7FFFFF, 0.99999994)
Math.succ(0.0)   = 34000000 (expected 00000001)
MathL.succ(-1.0) = BFF0000000000001 (expected BFEFFFFFFFFFFFFF)
MathL.pred(1.0)  = 3FEFFFFFFFFFFFFE (expected 3FEFFFFFFFFFFFFF)
(exit status 0)
```

## Cause and fix

succ(x) was x + ulp(x)*sign(x), so for a negative x it moved down, not
up: Math.succ(-1.0) was -1.0000001 and pred(-1.0) -0.9999999. And
ulp(x) is the spacing above |x|, not below it, so at a power of two
the step towards zero skipped a number: pred(1.0) was 1 - 2^-23, not
1 - 2^-24 (MathL: 1 - 2^-52, not 1 - 2^-53). succ(0.0) gave 2^-23,
the ulp of 1.0.

succ and pred now step the number's bit pattern, read as an integer, by
one: up in magnitude or down, by the sign. succ(0.0) is the smallest
positive denormal, pred(0.0) its negative.

With the fix:

```
$ ./SuccPred
Math.succ(-1.0)  = BF7FFFFF (expected BF7FFFFF, -0.99999994)
Math.pred(-1.0)  = BF800001 (expected BF800001, -1.0000001)
Math.pred(1.0)   = 3F7FFFFF (expected 3F7FFFFF, 0.99999994)
Math.succ(0.0)   = 00000001 (expected 00000001)
MathL.succ(-1.0) = BFEFFFFFFFFFFFFF (expected BFEFFFFFFFFFFFFF)
MathL.pred(1.0)  = 3FEFFFFFFFFFFFFF (expected 3FEFFFFFFFFFFFFF)
(exit status 0)
```

The fix is `patches/0039-Math-and-MathL-succ-and-pred-give-the-neighbouring-n.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
