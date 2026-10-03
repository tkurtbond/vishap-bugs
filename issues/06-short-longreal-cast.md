# SHORT of a LONGREAL is not rounded to REAL inside an expression

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`LONG(SHORT(x))` and `SHORT(x) * 1.0D0` are `x` itself, not `x` rounded to
`REAL`: the narrowing happens only when the result is stored in a `REAL`
variable.

## Reproducer

`LongShort.Mod`:

```oberon
MODULE LongShort; (* SHORT(x) of a LONGREAL is not rounded to REAL inside an expression *)
IMPORT Out;
VAR x, y, z: LONGREAL; r: REAL;
BEGIN
  x := 0.1D0;
  r := SHORT(x);                    (* rounded to REAL: stored in a REAL *)
  y := LONG(SHORT(x));              (* should be the same value *)
  z := SHORT(x) * 1.0D0;            (* SHORT(x) is a REAL operand: the same value again *)
  IF y = LONG(r) THEN Out.String("ok") ELSE Out.String("LONG(SHORT(x)) is x, not x rounded to REAL") END; Out.Ln;
  IF z = LONG(r) THEN Out.String("ok") ELSE Out.String("SHORT(x) * 1.0D0 is x, not x rounded to REAL") END; Out.Ln
END LongShort.
```

With voc at `master`:

```
$ voc -O2 LongShort.Mod -m
LongShort.Mod  Compiling LongShort.  Main program.  876 chars.
$ ./LongShort
LONG(SHORT(x)) is x, not x rounded to REAL
SHORT(x) * 1.0D0 is x, not x rounded to REAL
(exit status 0)
```

## Cause and fix

OPV.Convert wrote no cast for a LONGREAL to REAL conversion, relying on
C's conversion on assignment. Inside an expression nothing converts, so
LONG(SHORT(x)) and SHORT(x) * 1.0D0 were x itself, not x rounded to
REAL. It now writes (REAL).

With the fix:

```
$ ./LongShort
ok
ok
(exit status 0)
```

The fix is `patches/0006-Round-SHORT-of-a-LONGREAL-to-REAL-where-it-is-used-n.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
