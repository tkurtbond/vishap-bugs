# Real literals below the smallest normal number are "number too large"

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

A `REAL` literal below about 1.0E-37 and a `LONGREAL` literal below about
1.0D-307 are rejected with err 203, "number too large", so even the smallest
normal numbers, 1.17549435E-38 and 2.2250738585072014D-308, cannot be
written, nor any denormal, nor `0.0D-400`.

## Reproducer

`SmallLiteral.Mod`:

```oberon
MODULE SmallLiteral; (* a literal below about 1D-307 (or 1E-37) is "number too large" *)
IMPORT SYSTEM, Out;
CONST minNormal = 2.2250738585072014D-308; minNormalReal = 1.17549435E-38;
VAR h: HUGEINT; x: LONGREAL; i: SYSTEM.INT32; r: REAL;
BEGIN
  x := minNormal; h := SYSTEM.VAL(HUGEINT, x);
  Out.Hex(h, 16); Out.String(" (expected 0010000000000000)"); Out.Ln;
  r := minNormalReal; i := SYSTEM.VAL(SYSTEM.INT32, r);
  Out.Hex(i, 8); Out.String(" (expected 00800000)"); Out.Ln
END SmallLiteral.
```

`Denormal.Mod`:

```oberon
MODULE Denormal; (* the smallest denormals as literals *)
IMPORT SYSTEM, Out;
VAR h: HUGEINT; x: LONGREAL; i: SYSTEM.INT32; r: REAL;
BEGIN
  x := 4.9406564584124654D-324; h := SYSTEM.VAL(HUGEINT, x); Out.Hex(h, 16); Out.String(" (expected 0000000000000001)"); Out.Ln;
  r := 1.4E-45; i := SYSTEM.VAL(SYSTEM.INT32, r); Out.Hex(i, 8); Out.String(" (expected 00000001)"); Out.Ln;
  x := 0.0D-400; h := SYSTEM.VAL(HUGEINT, x); Out.Hex(h, 16); Out.String(" (expected 0000000000000000)"); Out.Ln
END Denormal.
```

`TinyLiteral.Mod`:

```oberon
MODULE TinyLiteral; (* expected: an error, the literal is not 0 but rounds to 0 *)
CONST tiny = 1.0D-400;
END TinyLiteral.
```

With voc at `master`:

```
$ voc -O2 SmallLiteral.Mod -m
SmallLiteral.Mod  Compiling SmallLiteral.
   3: CONST minNormal = 2.2250738585072014D-308; minNormalReal = 1.17549435E-38;
                      ^
    pos   125  err 203  number too large
   3: CONST minNormal = 2.2250738585072014D-308; minNormalReal = 1.17549435E-38;
                                                               ^
    pos   166  err 203  number too large
Module compilation failed.
(voc's exit status 1)
```

```
$ voc -O2 Denormal.Mod -m
Denormal.Mod  Compiling Denormal.
   5:   x := 4.9406564584124654D-324; h := SYSTEM.VAL(HUGEINT, x); Out.Hex(h, 16); Out.String(" (expected 0000000000000001)"); Out.Ln;
           ^
    pos   144  err 203  number too large
   6:   r := 1.4E-45; i := SYSTEM.VAL(SYSTEM.INT32, r); Out.Hex(i, 8); Out.String(" (expected 00000001)"); Out.Ln;
           ^
    pos   273  err 203  number too large
   7:   x := 0.0D-400; h := SYSTEM.VAL(HUGEINT, x); Out.Hex(h, 16); Out.String(" (expected 0000000000000000)"); Out.Ln
           ^
    pos   382  err 203  number too large
Module compilation failed.
(voc's exit status 1)
```

```
$ voc -O2 TinyLiteral.Mod -m
TinyLiteral.Mod  Compiling TinyLiteral.
   2: CONST tiny = 1.0D-400;
                 ^
    pos    94  err 203  number too large
Module compilation failed.
(voc's exit status 1)
```

## Cause and fix

The scanner refused a REAL literal below about 1.0E-37 and a LONGREAL
one below about 1.0D-307 with err 203, "number too large": the
smallest normal numbers themselves, 1.17549435E-38 and
2.2250738585072014D-308, could not be written, nor any denormal.
(Math and MathL work around it: Math.small is 1/8.50705917E37 and
MathL.small 2.2250738585072014/9.9999999999999981D307.) Such a literal
is now rounded as C rounds it, to a denormal; one that is not 0 but
rounds to 0, such as 1.0D-400, is still an error (203).

With the fix:

```
$ ./SmallLiteral
0010000000000000 (expected 0010000000000000)
00800000 (expected 00800000)
(exit status 0)
```

```
$ ./Denormal
0000000000000001 (expected 0000000000000001)
00000001 (expected 00000001)
0000000000000000 (expected 0000000000000000)
(exit status 0)
```

```
$ voc -O2 TinyLiteral.Mod -m
TinyLiteral.Mod  Compiling TinyLiteral.
   2: CONST tiny = 1.0D-400;
                 ^
    pos    94  err 203  number too large
Module compilation failed.
(voc's exit status 1)
```

The fix is `patches/0040-Accept-real-literals-below-the-smallest-normal-numbe.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0002 (Real literals are not correctly rounded); patch 0004 (REAL literals of 1.0E38 or more and LONGREAL literals of 1.0D308 or more are "number too large").

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
