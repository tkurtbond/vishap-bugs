# Integral LONGREAL literals >= 2^31 and constant ENTIER >= 2^31 halt the compiler under -OC

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Under `-OC`, an integral `LONGREAL` literal of 2^31 or more (`2147483648.0D0`,
`1.0D10`) and a constant `ENTIER` of such a value (`ENTIER(3000000000.5D0)`)
stop the compiler with `Halt(-8)`, "Value out of range". Both come from the
same place: the compiler's own `ENTIER`, which is 32 bits wide.

## Reproducer

`LongRealLiteral.Mod`:

```oberon
MODULE LongRealLiteral; (* integral LONGREAL literals >= 2^31 are rejected *)
IMPORT Out;
VAR x: LONGREAL;
BEGIN
  x := 2147483647.0D0; Out.LongReal(x, 0); Out.Ln;  (* compiles *)
  x := 2147483648.0D0; Out.LongReal(x, 0); Out.Ln;  (* err: Value out of range *)
  x := 1.0D10;         Out.LongReal(x, 0); Out.Ln;  (* err: Value out of range *)
  x := 1.5D10;         Out.LongReal(x, 0); Out.Ln   (* err: Value out of range *)
END LongRealLiteral.
```

`ConstEntier.Mod`:

```oberon
MODULE ConstEntier; (* a constant ENTIER >= 2^31 stops the compiler under -OC *)
IMPORT Out;
CONST big = ENTIER(3000000000.5D0);
BEGIN
  Out.Int(big, 0); Out.Ln  (* expected 3000000000 *)
END ConstEntier.
```

With voc at `master`:

```
$ voc -OC LongRealLiteral.Mod -m
Terminated by Halt(-8). Value out of range.
(voc's exit status 248)
```

```
$ voc -OC ConstEntier.Mod -m
Terminated by Halt(-8). Value out of range.
(voc's exit status 248)
```

## Cause and fix

The compiler is built with the -O2 sizes, so its own ENTIER yields a 32
bit LONGINT, which halts with "Value out of range" for anything that
needs more. Under -OC it took that ENTIER of constants that do:
OPM.WriteReal of any integral LONGREAL constant below 2^63 (so a literal
2147483648.0D0 or 1.0D10 stopped the compiler), and OPB.Convert folding a
constant ENTIER (ENTIER(3000000000.5D0)). OPM.Entier64 computes the 64
bit value in pieces. OPB.Convert's upper bound is also made exclusive:
2^63 does not fit.

With the fix:

```
$ ./LongRealLiteral
2.147483647D+009
2.147483648D+009
1.0D+010
1.5D+010
(exit status 0)
```

```
$ ./ConstEntier
3000000000
(exit status 0)
```

The fix is `patches/0001-Take-ENTIER-of-constants-2-31-in-64-bits-in-the-comp.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
