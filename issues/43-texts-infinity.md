# Texts writes an infinity as NaN

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Texts.WriteReal`, `WriteLongReal` and `WriteRealFix` write " NaN" for
positive and negative infinity.

## Reproducer

`TextsInf.Mod`:

```oberon
MODULE TextsInf; (* Texts writes an infinity as "NaN" *)
IMPORT Texts, Oberon, Out;
VAR W: Texts.Writer; T: Texts.Text; R: Texts.Reader; ch: CHAR; x, zero: REAL; y: LONGREAL;
BEGIN
  Texts.OpenWriter(W); zero := 0.0;
  x := 1.0 / zero; y := x;
  Texts.WriteReal(W, x, 12); Texts.WriteString(W, " (expected  Infinity)"); Texts.WriteLn(W);
  Texts.WriteReal(W, -x, 12); Texts.WriteString(W, " (expected -Infinity)"); Texts.WriteLn(W);
  Texts.WriteLongReal(W, y, 12); Texts.WriteString(W, " (expected  Infinity)"); Texts.WriteLn(W);
  Texts.WriteRealFix(W, x, 12, 2); Texts.WriteString(W, " (expected  Infinity)"); Texts.WriteLn(W);
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO IF ch = 0DX THEN Out.Ln ELSE Out.Char(ch) END; Texts.Read(R, ch) END
END TextsInf.
```

With voc at `master`:

```
$ voc -O2 TextsInf.Mod -m
TextsInf.Mod  Compiling TextsInf.  Main program.  2155 chars.
$ ./TextsInf
 NaN         (expected  Infinity)
 NaN         (expected -Infinity)
 NaN         (expected  Infinity)
 NaN         (expected  Infinity)
(exit status 0)
```

## Cause and fix

WriteReal, WriteLongReal and WriteRealFix wrote " NaN" for any number
whose exponent field is all ones, so an infinity, positive or negative,
was written as NaN. A NaN is still " NaN"; an infinity is now written
" Infinity" or "-Infinity", as Out.Real writes it, padded with blanks
to n characters as before.

With the fix:

```
$ ./TextsInf
 Infinity    (expected  Infinity)
-Infinity    (expected -Infinity)
 Infinity    (expected  Infinity)
 Infinity    (expected  Infinity)
(exit status 0)
```

The fix is `patches/0043-Texts-an-infinity-is-written-as-Infinity-not-NaN.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
