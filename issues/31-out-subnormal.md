# Out.LongReal writes a subnormal number as 0

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Any subnormal `LONGREAL` (4.9D-324 up to 2.2D-308) is written as
`0.0D+000`.

## Reproducer

`OutSubnormal.Mod`:

```oberon
MODULE OutSubnormal; (* Out.LongReal writes a subnormal number as 0 *)
IMPORT SYSTEM, Out;
VAR d: LONGREAL; bits: SYSTEM.INT64;
BEGIN
  bits := 1; SYSTEM.GET(SYSTEM.ADR(bits), d);                 (* the smallest double, 4.9D-324 *)
  Out.LongReal(d, 0); Out.String(" (expected 4.9D-324)"); Out.Ln;
  bits := 8000000000000H; SYSTEM.GET(SYSTEM.ADR(bits), d);    (* 2^-1023, 1.1D-308 *)
  Out.LongReal(d, 0); Out.String(" (expected 1.1D-308)"); Out.Ln
END OutSubnormal.
```

With voc at `master`:

```
$ voc -O2 OutSubnormal.Mod -m
OutSubnormal.Mod  Compiling OutSubnormal.  Main program.  776 chars.
$ ./OutSubnormal
0.0D+000 (expected 4.9D-324)
0.0D+000 (expected 1.1D-308)
(exit status 0)
```

## Cause and fix

RealP took a zero exponent field for zero, so a subnormal LONGREAL (from
4.9D-324 up to 2.2D-308) was written 0.0D+000. It is now scaled by 10^20
into the normal range and written with its exponent. (A REAL is written
through a LONGREAL, in which no REAL is subnormal.)

With the fix:

```
$ ./OutSubnormal
4.94065645841247D-324 (expected 4.9D-324)
1.1125369292536D-308 (expected 1.1D-308)
(exit status 0)
```

The fix is `patches/0031-Out.LongReal-writes-a-subnormal-number-not-0.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
