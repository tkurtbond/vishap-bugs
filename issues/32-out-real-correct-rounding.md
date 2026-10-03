# Out.LongReal does not write correctly rounded digits

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Out.LongReal` makes the digits by scaling with rounded powers of ten, so
they are often not the digits of the number: 1/7 is written
1.4285714285714284D-001, not ...285. Of 2000 random doubles written with 17
significant digits, 1677 did not read back as the same double, though 17
digits always suffice. (`Out.Real` goes through the same code.)

## Reproducer

`OutRound.Mod`:

```oberon
MODULE OutRound; (* Out.LongReal does not write correctly rounded digits *)
IMPORT Out;
PROCEDURE Show(i: INTEGER; expected: ARRAY OF CHAR);
  VAR d: LONGREAL;
BEGIN
  d := i; d := d / 7.0D0;
  Out.Int(i, 2); Out.String("/7 = "); Out.LongReal(d, 24);
  Out.String(" (expected "); Out.String(expected); Out.String(")"); Out.Ln
END Show;
BEGIN
  Show(1, "1.4285714285714285D-001");
  Show(4, "5.7142857142857140D-001");
  Show(27, "3.8571428571428572D+000")  (* what voc writes reads back as another double *)
END OutRound.
```

With voc at `master`:

```
$ voc -O2 OutRound.Mod -m
OutRound.Mod  Compiling OutRound.  Main program.  955 chars.
$ ./OutRound
 1/7 =  1.4285714285714284D-001 (expected 1.4285714285714285D-001)
 4/7 =  5.7142857142857136D-001 (expected 5.7142857142857140D-001)
27/7 =  3.8571428571428576D+000 (expected 3.8571428571428572D+000)
(exit status 0)
```

## Cause and fix

RealP scaled x by powers of ten made by repeated squaring (Ten) and
rounded the scaled value, each step rounding, so the digits were often
not those of x: of 2000 random doubles written with 17 significant
digits (LongReal(x, 24)), 1677 did not read back as the same double,
though 17 digits always suffice. The digits and the exponent now come
from snprintf's "%.*e", which rounds correctly; the formatting around
them (width, trailing zeroes, the exponent's form) is as before.

The confidence test out's expected digits change to the ones the doubles
really have: 1.1D0 is 1.10000000000000008882, so 17 digits are
1.1000000000000001, and 1.2345678987654321D3 is written
1.2345678987654321D+003, not 1.2345678987654320D+003. The confidence
test math's change the same way: they are now the digits of the values
MathL returns (MathL.sqrt(2.0D0) is 1.4142135623730949, an ulp below the
correctly rounded square root, so 15 digits are 1.41421356237309, and
MathL.tanh(0.9) ends in 024, not 025).

With the fix:

```
$ ./OutRound
 1/7 =  1.4285714285714285D-001 (expected 1.4285714285714285D-001)
 4/7 =  5.7142857142857140D-001 (expected 5.7142857142857140D-001)
27/7 =  3.8571428571428572D+000 (expected 3.8571428571428572D+000)
(exit status 0)
```

The fix is `patches/0032-Out.Real-and-LongReal-correctly-rounded-digits-from-.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0030 (Out.Real and Out.LongReal write a wrong exponent when rounding carries); patch 0031 (Out.LongReal writes a subnormal number as 0).

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
