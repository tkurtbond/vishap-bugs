# Strings.Replace deletes pos + Length(source) characters

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Strings.Replace("XY", 3, s)` with `s = "abcdefgh"` gives `abcXY`, not
`abcXYfgh`: it deletes `pos + Length(source)` characters instead of
`Length(source)`.

## Reproducer

`StringsReplace.Mod`:

```oberon
MODULE StringsReplace; (* Strings.Replace deletes pos + Length(source) characters *)
IMPORT Strings, Out;
VAR s: ARRAY 32 OF CHAR;
BEGIN
  s := "abcdefgh"; Strings.Replace("XY", 3, s);
  Out.String(s); Out.String(" (expected abcXYfgh)"); Out.Ln
END StringsReplace.
```

With voc at `master`:

```
$ voc -O2 StringsReplace.Mod -m
StringsReplace.Mod  Compiling StringsReplace.  Main program.  621 chars.
$ ./StringsReplace
abcXY (expected abcXYfgh)
(exit status 0)
```

## Cause and fix

It deleted pos + Length(source), so Replace("XY", 3, s) of abcdefgh gave
abcXY. Oakwood: "Replace(src, pos, dst) has the same effect as
Delete(dst, pos, Length(src)) followed by an Insert(src, pos, dst)."

With the fix:

```
$ ./StringsReplace
abcXYfgh (expected abcXYfgh)
(exit status 0)
```

The fix is `patches/0019-Strings.Replace-deletes-Length-source-characters.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
