# Texts.WriteInt of MIN(SYSTEM.INT64) ignores the width

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Texts.WriteInt(W, MIN(SYSTEM.INT64), n)` always writes
` -9223372036854775808`, with one blank, whatever `n` is: too few blanks
for a wide field, and one too many for `n` = 0.

## Reproducer

`TextsWriteIntMin.Mod`:

```oberon
MODULE TextsWriteIntMin; (* Texts.WriteInt of MIN(SYSTEM.INT64) ignores the width *)
IMPORT SYSTEM, Texts, Out;
VAR W: Texts.Writer; T: Texts.Text; R: Texts.Reader; ch: CHAR;
BEGIN
  Texts.OpenWriter(W);
  Texts.Write(W, "["); Texts.WriteInt(W, MIN(SYSTEM.INT64), 24); Texts.Write(W, "]");
  Texts.WriteString(W, " (expected [    -9223372036854775808])"); Texts.WriteLn(W);
  Texts.Write(W, "["); Texts.WriteInt(W, MIN(SYSTEM.INT64), 0); Texts.Write(W, "]");
  Texts.WriteString(W, " (expected [-9223372036854775808])");
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO IF ch = 0DX THEN Out.Ln ELSE Out.Char(ch) END; Texts.Read(R, ch) END; Out.Ln
END TextsWriteIntMin.
```

With voc at `master`:

```
$ voc -O2 TextsWriteIntMin.Mod -m
TextsWriteIntMin.Mod  Compiling TextsWriteIntMin.  Main program.  2010 chars.
$ ./TextsWriteIntMin
[ -9223372036854775808] (expected [    -9223372036854775808])
[ -9223372036854775808] (expected [-9223372036854775808])
(exit status 0)
```

## Cause and fix

WriteInt wrote the most negative 64-bit integer as the fixed string
" -9223372036854775808", whatever the width n: one blank where n asked
for more, and one where n asked for none. Every other number is padded
with blanks to n characters.

WriteInt now takes that number's digits from a constant, since it has no
negation, and pads it like any other number.

With the fix:

```
$ ./TextsWriteIntMin
[    -9223372036854775808] (expected [    -9223372036854775808])
[-9223372036854775808] (expected [-9223372036854775808])
(exit status 0)
```

The fix is `patches/0053-Texts.WriteInt-MIN-SYSTEM.INT64-is-padded-to-the-wid.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
