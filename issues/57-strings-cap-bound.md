# Strings.Cap runs off the end of an array with no 0X

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Strings.Cap(s)` looks for the 0X that ends `s` with no bound, so a
string that fills its array traps with an index out of range (or, with
index checks off, changes memory beyond the array).

## Reproducer

`StringsCap.Mod`:

```oberon
MODULE StringsCap; (* Strings.Cap of an array that is full, with no 0X *)
IMPORT Strings, Out;
VAR s: ARRAY 4 OF CHAR;
BEGIN
  s[0] := "a"; s[1] := "b"; s[2] := "c"; s[3] := "d";
  Strings.Cap(s);
  Out.Char(s[0]); Out.Char(s[1]); Out.Char(s[2]); Out.Char(s[3]);
  Out.String(" (expected ABCD)"); Out.Ln
END StringsCap.
```

With voc at `master`:

```
$ voc -O2 StringsCap.Mod -m
StringsCap.Mod  Compiling StringsCap.  Main program.  711 chars.
$ ./StringsCap
Terminated by Halt(-2). Index out of range.
(exit status 254)
```

## Cause and fix

Cap looked for the 0X that ends the string with no bound, so a string
that fills its array, with no 0X, made it run off the end: an index out
of range with index checks, and memory beyond the array changed without
them. Strings.Length, which the other procedures use, stops at the end
of the array.

Cap now stops at the 0X or at the end of the array, whichever comes
first.

With the fix:

```
$ ./StringsCap
ABCD (expected ABCD)
(exit status 0)
```

The fix is `patches/0057-Strings.Cap-stop-at-the-end-of-the-array.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
