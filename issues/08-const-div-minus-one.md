# Constant MIN(HUGEINT) DIV (-1) crashes the compiler with SIGFPE

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Folding `MIN(HUGEINT) DIV (-1)`, whose value does not fit, kills the
compiler with a floating point exception instead of reporting an error.

## Reproducer

`ConstDivMinusOne.Mod`:

```oberon
MODULE ConstDivMinusOne; (* folding MIN(HUGEINT) DIV (-1) kills the compiler with SIGFPE *)
IMPORT Out;
CONST q = MIN(HUGEINT) DIV (-1);           (* does not fit: should be an error *)
BEGIN
  Out.Int(q, 0); Out.Ln
END ConstDivMinusOne.
```

With voc at `master`:

```
$ voc -O2 ConstDivMinusOne.Mod -m
(voc killed by SIGFPE)
```

## Cause and fix

OPB.ConstOp divided without checking for the one quotient that does not
fit, and the compiler died of SIGFPE (C's division of the minimum by -1
traps on x86). It is now err 203, number too large.

With the fix:

```
$ voc -O2 ConstDivMinusOne.Mod -m
ConstDivMinusOne.Mod  Compiling ConstDivMinusOne.
   3: CONST q = MIN(HUGEINT) DIV (-1);           (* does not fit: should be an error *)
                                    ^
    pos   134  err 203  number too large
Module compilation failed.
(voc's exit status 1)
```

The fix is `patches/0008-Constant-MIN-SYSTEM.INT64-DIV-1-is-an-error-not-a-co.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
