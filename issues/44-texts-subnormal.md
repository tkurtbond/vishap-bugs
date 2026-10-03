# Texts writes a subnormal number as 0

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Texts.WriteReal` of 2^-149 (1.4E-45) and `Texts.WriteLongReal` of 2^-1074
(4.9D-324) write `0`.

## Reproducer

`TextsSubnormal.Mod`:

```oberon
MODULE TextsSubnormal; (* Texts writes a subnormal number as 0 *)
IMPORT SYSTEM, Texts, Out;
VAR W: Texts.Writer; T: Texts.Text; R: Texts.Reader; ch: CHAR;
  x: REAL; y: LONGREAL; i: SYSTEM.INT32; h: HUGEINT;
BEGIN
  Texts.OpenWriter(W);
  i := 1; x := SYSTEM.VAL(REAL, i);  (* 2^-149 *)
  Texts.WriteReal(W, x, 14); Texts.WriteString(W, " (expected  1.401298E-45)"); Texts.WriteLn(W);
  h := 1; y := SYSTEM.VAL(LONGREAL, h);  (* 2^-1074 *)
  Texts.WriteLongReal(W, y, 23); Texts.WriteString(W, " (expected  4.94065645841247D-324)"); Texts.WriteLn(W);
  y := 0.0D0; Texts.WriteLongReal(W, y, 23); Texts.WriteString(W, " (expected  0, as before)"); Texts.WriteLn(W);
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO IF ch = 0DX THEN Out.Ln ELSE Out.Char(ch) END; Texts.Read(R, ch) END; Out.Ln
END TextsSubnormal.
```

With voc at `master`:

```
$ voc -O2 TextsSubnormal.Mod -m
TextsSubnormal.Mod  Compiling TextsSubnormal.  Main program.  2293 chars.
$ ./TextsSubnormal
  0            (expected  1.401298E-45)
  0                     (expected  4.94065645841247D-324)
  0                     (expected  0, as before)

(exit status 0)
```

## Cause and fix

WriteReal and WriteLongReal took an exponent field of 0 to mean zero,
but it is also the field of every subnormal number, so 2^-149 (1.4E-45)
and 2^-1074 (4.9D-324) were written as 0. Zero is now x = 0, and a
subnormal number is first scaled by 10^20 into the normal range, its
decimal exponent reduced by 20 again.

With the fix:

```
$ ./TextsSubnormal
  1.401298E-45 (expected  1.401298E-45)
  4.94065645841247D-324 (expected  4.94065645841247D-324)
  0                     (expected  0, as before)

(exit status 0)
```

The fix is `patches/0044-Texts-a-subnormal-number-is-written-with-its-digits-.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
