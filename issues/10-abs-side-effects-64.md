# ABS of a 64-bit argument with side effects is cut to 32 bits

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Under `-OC`, `ABS(a[Next()])` with `a[1] = -5000000000` is 705032704: when
the argument has side effects, the 64-bit and 32-bit helper functions are
called the wrong way round.

## Reproducer

`Abs64.Mod`:

```oberon
MODULE Abs64; (* ABS of a 64-bit value with side effects is cut to 32 bits *)
IMPORT Out;
VAR a: ARRAY 2 OF LONGINT; i: LONGINT;
PROCEDURE Next(): LONGINT; BEGIN INC(i); RETURN i END Next;
BEGIN (* compile with -OC: LONGINT is 64 bits *)
  a[1] := -5000000000; i := 0;
  Out.Int(ABS(a[Next()]), 0); Out.String(" (expected 5000000000)"); Out.Ln
END Abs64.
```

With voc at `master`:

```
$ voc -OC Abs64.Mod -m
Abs64.Mod  Compiling Abs64.  Main program.  633 chars.
$ ./Abs64
705032704 (expected 5000000000)
(exit status 0)
```

## Cause and fix

SYSTEM_ABS64 and SYSTEM_ABS32, which __ABSF calls when the argument has
side effects, had their result types swapped: ABS(a[Next()]) of
-5000000000 under -OC was 705032704.

With the fix:

```
$ ./Abs64
5000000000 (expected 5000000000)
(exit status 0)
```

The fix is `patches/0010-ABS-of-a-64-bit-argument-with-side-effects-is-not-cu.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
