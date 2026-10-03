# REAL literals of 1.0E38 or more and LONGREAL literals of 1.0D308 or more are "number too large"

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`3.4E38` and `1.7D308` are within range (`MAX(REAL)` is about 3.40282E38,
`MAX(LONGREAL)` about 1.79769D308) but are rejected with err 203, "number
too large". No value near the top of either range can be written as a
literal.

## Reproducer

`RealExponent.Mod`:

```oberon
MODULE RealExponent; (* REAL literals with exponent 38, LONGREAL with 308, are "too large" *)
IMPORT Out;
VAR r: REAL; d: LONGREAL;
BEGIN
  r := 3.4E38;  Out.Real(r, 0); Out.Ln;      (* MAX(REAL) is about 3.40282E38 *)
  d := 1.7D308; Out.LongReal(d, 0); Out.Ln   (* MAX(LONGREAL) is about 1.79769D308 *)
END RealExponent.
```

With voc at `master`:

```
$ voc -O2 RealExponent.Mod -m
RealExponent.Mod  Compiling RealExponent.
   5:   r := 3.4E38;  Out.Real(r, 0); Out.Ln;      (* MAX(REAL) is about 3.40282E38 *)
           ^
    pos   143  err 203  number too large
   6:   d := 1.7D308; Out.LongReal(d, 0); Out.Ln   (* MAX(LONGREAL) is about 1.79769D308 *)
           ^
    pos   224  err 203  number too large
Module compilation failed.
(voc's exit status 1)
```

## Cause and fix

OPS.Number makes the value 0.ddd * 10^e and accepted only e <= MaxRExp
(MaxLExp), so every literal of 10^38 (10^308) or more was "number too
large", though REAL (LONGREAL) holds up to 3.40282347E38
(1.7976931348623157D308). One more e is accepted now, and a literal is
too large when strtof (strtod) rounds it to infinity.

With the fix:

```
$ ./RealExponent
3.4E+38
1.7D+308
(exit status 0)
```

The fix is `patches/0004-Accept-real-literals-from-1.0E38-to-MAX-REAL-1.0D308.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0002 (Real literals are not correctly rounded).

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
