# ethReals reads the wrong half of a LONGREAL, so ethStrings.RealToStr writes nonsense

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`ethReals` keeps the offsets of a `LONGREAL`'s high and low 32 bits in
the variables `H` and `L`, which nothing sets, so both are 0. On a
little-endian machine `ExpoL`, `SetExpoL`, `RealL` and `IntL` then take
the low half for the high one, and `ethStrings.RealToStr`, which uses
them, writes nonsense: `RealToStr(12345.678D0, s)` gives
`0.000000000000005D+042`, and `RealToStr(3.0D0, s)` gives `0`.

## Reproducer

`EthReals.Mod`:

```oberon
MODULE EthReals; (* ethReals reads the wrong half of a LONGREAL, so ethStrings.RealToStr is wrong *)
IMPORT ethReals, ethStrings, Out;
VAR s: ARRAY 32 OF CHAR;
BEGIN
  Out.String("ethReals.ExpoL(12345.678D0) "); Out.Int(ethReals.ExpoL(12345.678D0), 0);
  Out.String(" (expected 1036)"); Out.Ln;
  ethStrings.RealToStr(12345.678D0, s); Out.String(s); Out.String(" (expected 12345.678)"); Out.Ln;
  ethStrings.RealToStr(0.25D0, s); Out.String(s); Out.String(" (expected 0.25)"); Out.Ln;
  ethStrings.RealToStr(3.0D0, s); Out.String(s); Out.String(" (expected 3)"); Out.Ln
END EthReals.
```

With voc at `master`:

```
$ voc -O2 EthReals.Mod -m
EthReals.Mod  Compiling EthReals.  Main program.  1083 chars.
$ ./EthReals
ethReals.ExpoL(12345.678D0) 1163 (expected 1036)
0.000000000000005D+042 (expected 12345.678)
0 (expected 0.25)
0 (expected 3)
(exit status 0)
```

## Cause and fix

ExpoL, SetExpoL, RealL and IntL read and write a LONGREAL's high and
low 32 bits at the offsets H and L, which the comment says to set for
the machine's byte order, and which the module used to set with a
dynamic test ("7.11.1995 jt: dynamic endianess test"). Nothing sets them
now, so both are 0, and on a little-endian machine every one of these
procedures uses the low half for the high one: ethReals.ExpoL(12345.678D0)
is 1163, not 1036. ethReals.Ten uses ExpoL and SetExpoL, and
ethStrings.RealToStr and RealToFixStr use ExpoL, so
ethStrings.RealToStr(12345.678D0, s) gave "0.000000000000005D+042", and
RealToStr of 0.25 and of 3.0 gave "0".

The module body now sets H and L from Platform.LittleEndian.

With the fix:

```
$ ./EthReals
ethReals.ExpoL(12345.678D0) 1036 (expected 1036)
12345.678 (expected 12345.678)
0.25 (expected 0.25)
3 (expected 3)
(exit status 0)
```

The fix is `patches/0067-ethReals-set-H-and-L-the-offsets-of-a-LONGREAL-s-two.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
