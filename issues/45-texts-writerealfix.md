# Texts.WriteRealFix drops decimals and traps on numbers with more than 9 digits before the point

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Texts.WriteRealFix(W, 1234.5, 12, 6)` writes `1234.50008`: decimals are
dropped to stay within 9 digits, and the digits beyond REAL's precision are
noise. `WriteRealFix(W, 0.0006, 8, 3)` writes `0.0000`. A number with more than
9 digits before the point, such as 1.0E10, stops the program with "Index out
of range".

## Reproducer

`TextsFix.Mod`:

```oberon
MODULE TextsFix; (* Texts.WriteRealFix drops decimals, and goes wrong past 9 digits *)
IMPORT Texts, Out;
VAR W: Texts.Writer; T: Texts.Text; R: Texts.Reader; ch: CHAR; x: REAL;
PROCEDURE F(x: REAL; n, k: INTEGER; expected: ARRAY OF CHAR);
BEGIN (* each line is written out at once, before the next WriteRealFix *)
  Texts.WriteString(W, "["); Texts.WriteRealFix(W, x, n, k); Texts.WriteString(W, "] (expected [");
  Texts.WriteString(W, expected); Texts.WriteString(W, "])");
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO Out.Char(ch); Texts.Read(R, ch) END; Out.Ln
END F;
BEGIN
  Texts.OpenWriter(W);
  F(3.25, 8, 2, "    3.25");
  F(1234.5, 12, 6, " 1234.500000");
  F(123456.0, 12, 4, " 123456.0000");
  F(0.0006, 8, 3, "   0.001");
  F(0.0004, 8, 3, "   0.000");
  F(0.6, 4, 0, "  1.");
  F(-0.125, 8, 2, "   -0.13");
  F(9.9999, 8, 2, "   10.00");
  x := 1.5E6; x := x * 1.0E6; F(x, 18, 1, "   1500000030000.0");  (* REAL 1500000026624, 9 digits *)
  x := 1.0E5; x := x * x; F(x, 16, 2, "  10000000000.00")      (* 1.0E10, made at run time *)
END TextsFix.
```

With voc at `master`:

```
$ voc -O2 TextsFix.Mod -m
TextsFix.Mod  Compiling TextsFix.  Main program.  2446 chars.
$ ./TextsFix
[    3.25] (expected [    3.25])
[  1234.50008] (expected [ 1234.500000])
[  123456.000] (expected [ 123456.0000])
[  0.0000] (expected [   0.001])
[  0.0000] (expected [   0.000])
[ 0.0] (expected [  1.])
[   -0.13] (expected [   -0.13])
[   10.00] (expected [   10.00])
Terminated by Halt(-2). Index out of range.
(exit status 254)
```

## Cause and fix

WriteRealFix scaled x to its digits in REAL arithmetic and wrote at most
9 digits (maxD), dropping decimals to stay within them, and the digits
beyond REAL's precision were noise: WriteRealFix(1234.5, 12, 6) wrote
1234.50008. With more than 9 digits before the point, k became negative
and the digit array was indexed out of range: WriteRealFix(1.0E10, 16, 2)
stopped the program (index out of range).

The digits are now computed in LONGREAL, which holds x exactly and its 9
digits without error, correctly rounded to at most maxD significant
digits; the k decimals asked for are always written, and any digit past
the 9th is 0. So 1234.5 with 6 decimals is 1234.500000, 1.0E10 with 2 is
10000000000.00, and 0.0006 with 3 rounds up to 0.001.

The confidence test texts writes -311.1415 with 7 decimals: it was
-311.141504, a decimal dropped and its last digit wrong (the REAL is
-311.14151000976...); it is now -311.1415100.

With the fix:

```
$ ./TextsFix
[    3.25] (expected [    3.25])
[ 1234.500000] (expected [ 1234.500000])
[ 123456.0000] (expected [ 123456.0000])
[   0.001] (expected [   0.001])
[   0.000] (expected [   0.000])
[  1.] (expected [  1.])
[   -0.13] (expected [   -0.13])
[   10.00] (expected [   10.00])
[   1500000030000.0] (expected [   1500000030000.0])
[  10000000000.00] (expected [  10000000000.00])
(exit status 0)
```

The fix is `patches/0045-Texts.WriteRealFix-the-decimals-asked-for-and-number.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
