# DIV and MOD give wrong results for a 64-bit dividend near MIN or MAX

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Under `-OC`, `MIN(LONGINT) DIV 2` is 4611686018427387903 (positive),
`(MIN(LONGINT) + 1) DIV 2` and `MAX(LONGINT) DIV (-2)` are positive, and
`MIN(LONGINT) MOD (-3)` is 2: the run-time `SYSTEM_DIV`/`SYSTEM_MOD`
overflow.

## Reproducer

`DivModMin.Mod`:

```oberon
MODULE DivModMin; (* DIV and MOD of a large negative dividend overflow in SYSTEM_DIV/SYSTEM_MOD *)
IMPORT Out;
VAR x, y: LONGINT;
BEGIN (* compile with -OC: LONGINT is 64 bits *)
  x := MIN(LONGINT); y := 2;
  Out.Int(x DIV y, 0); Out.String(" (expected -4611686018427387904)"); Out.Ln;
  Out.Int(x MOD y, 0); Out.String(" (expected 0)"); Out.Ln;
  x := MIN(LONGINT) + 1;
  Out.Int(x DIV y, 0); Out.String(" (expected -4611686018427387904)"); Out.Ln;
  Out.Int(x MOD y, 0); Out.String(" (expected 1)"); Out.Ln;
  x := MAX(LONGINT); y := -2;
  Out.Int(x DIV y, 0); Out.String(" (expected -4611686018427387904)"); Out.Ln;
  Out.Int(x MOD y, 0); Out.String(" (expected -1)"); Out.Ln;
  x := MIN(LONGINT); y := -3;
  Out.Int(x DIV y, 0); Out.String(" (expected 3074457345618258602)"); Out.Ln;
  Out.Int(x MOD y, 0); Out.String(" (expected -2)"); Out.Ln
END DivModMin.
```

With voc at `master`:

```
$ voc -OC DivModMin.Mod -m
DivModMin.Mod  Compiling DivModMin.  Main program.  1452 chars.
$ ./DivModMin
4611686018427387903 (expected -4611686018427387904)
0 (expected 0)
4611686018427387904 (expected -4611686018427387904)
1 (expected 1)
4611686018427387904 (expected -4611686018427387904)
-1 (expected -1)
3074457345618258602 (expected 3074457345618258602)
2 (expected -2)
(exit status 0)
```

## Cause and fix

With a 64 bit LONGINT, MIN(LONGINT) DIV 2 was 4611686018427387903,
(MIN(LONGINT) + 1) DIV 2 and MAX(LONGINT) DIV (-2) positive, and
MIN(LONGINT) MOD (-3) was 2: the functions negated x or added y to it
before dividing, which overflowed. They now take C's truncating quotient
and remainder and adjust them by one divisor when the signs differ. A
divisor of -1, the one case where C's division overflows, is handled
first; 0 DIV y and 0 MOD y stay 0 as before.

With the fix:

```
$ ./DivModMin
-4611686018427387904 (expected -4611686018427387904)
0 (expected 0)
-4611686018427387904 (expected -4611686018427387904)
1 (expected 1)
-4611686018427387904 (expected -4611686018427387904)
-1 (expected -1)
3074457345618258602 (expected 3074457345618258602)
-2 (expected -2)
(exit status 0)
```

The fix is `patches/0007-SYSTEM_DIV-SYSTEM_MOD-no-overflow-for-a-dividend-nea.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
