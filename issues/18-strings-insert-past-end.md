# Strings.Insert at a position past the end does nothing

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Strings.Insert("XYZ", 10, s)` with `s = "abc"` leaves `s` as it was; Oakwood
says the source is appended. `Insert` calls `Append` with its arguments the
wrong way round.

## Reproducer

`StringsInsertEnd.Mod`:

```oberon
MODULE StringsInsertEnd; (* Strings.Insert at a position past the end does nothing *)
IMPORT Strings, Out;
VAR s: ARRAY 32 OF CHAR;
BEGIN
  s := "abc"; Strings.Insert("XYZ", 10, s);
  Out.String(s); Out.String(" (expected abcXYZ)"); Out.Ln
END StringsInsertEnd.
```

With voc at `master`:

```
$ voc -O2 StringsInsertEnd.Mod -m
StringsInsertEnd.Mod  Compiling StringsInsertEnd.  Main program.  625 chars.
$ ./StringsInsertEnd
abc (expected abcXYZ)
(exit status 0)
```

## Cause and fix

Insert called Append(dest, source), its arguments the wrong way round:
source is a value parameter, so dest was left as it was. Oakwood:
"If pos = Length(dst), src is appended to dst."

With the fix:

```
$ ./StringsInsertEnd
abcXYZ (expected abcXYZ)
(exit status 0)
```

The fix is `patches/0018-Strings.Insert-at-a-position-past-the-end-appends.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
