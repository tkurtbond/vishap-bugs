# A HUGEINT variable cannot be passed to In.HugeInt

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`In.HugeInt(h)` with `h: HUGEINT` is err 123, "type of actual parameter is
not identical with that of formal VAR-parameter". `HUGEINT` is a type of its
own, but a symbol file records an 8-byte integer only by its size and reads
it back as `SYSTEM.INT64`, so an exported `VAR x: HUGEINT` parameter is a
`SYSTEM.INT64` one to importers.

## Reproducer

`InHugeInt.Mod`:

```oberon
MODULE InHugeInt; (* In.HugeInt: a HUGEINT variable is not accepted *)
IMPORT In, Out;
VAR h: HUGEINT;
BEGIN
  In.HugeInt(h); Out.Int(h, 0); Out.Ln
END InHugeInt.
```

With voc at `master`:

```
$ voc -O2 InHugeInt.Mod -m
InHugeInt.Mod  Compiling InHugeInt.
   5:   In.HugeInt(h); Out.Int(h, 0); Out.Ln
                   ^
    pos   122  err 123  type of actual parameter is not identical with that of formal VAR-parameter
Module compilation failed.
(voc's exit status 1)
```

## Cause and fix

HUGEINT was a type of its own, distinct from SYSTEM.INT64 though both
are 8 byte integers. A symbol file records an integer type by its size
only, and reads an 8 byte one back as SYSTEM.INT64, so an exported
HUGEINT VAR parameter became a SYSTEM.INT64 one to importers, and a
HUGEINT variable could not be passed to it: In.HugeInt(h) with h a
HUGEINT was err 123, "type of actual parameter is not identical with
that of formal VAR-parameter". HUGEINT now names the SYSTEM.INT64 type
itself, as LONGINT does under -OC.

With the fix:

```
$ printf '123\n' | ./InHugeInt
123
(exit status 0)
```

The fix is `patches/0024-Make-HUGEINT-another-name-for-SYSTEM.INT64.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
