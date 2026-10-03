# Strings.Pos with a negative start is an index trap

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Strings.Pos("c", "abc", -2)` stops with "Index out of range": it indexes
`s[pos]` with the negative `pos`. `Insert` and `Delete` already treat a
negative position as 0.

## Reproducer

`StringsPos.Mod`:

```oberon
MODULE StringsPos; (* Strings.Pos with a negative start *)
IMPORT Strings, Out;
BEGIN
  Out.Int(Strings.Pos("c", "abc", -2), 0); Out.String(" (expected 2)"); Out.Ln
END StringsPos.
```

With voc at `master`:

```
$ voc -O2 StringsPos.Mod -m
StringsPos.Mod  Compiling StringsPos.  Main program.  495 chars.
$ ./StringsPos
Terminated by Halt(-2). Index out of range.
(exit status 254)
```

## Cause and fix

It indexed s[pos] with pos as given, an index trap (or a read before s
without -x) for a negative pos. Insert and Delete already count a
negative position as 0.

With the fix:

```
$ ./StringsPos
2 (expected 2)
(exit status 0)
```

The fix is `patches/0022-Strings.Pos-with-a-negative-start-searches-from-0.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
