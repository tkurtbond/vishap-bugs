# CAP changes characters that are not lower-case letters

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`CAP` clears bit 5, so `CAP("7")` is 17X, `CAP("{")` is `[` and `CAP("`")`
is `@`, at run time and in constants alike.

## Reproducer

`Cap.Mod`:

```oberon
MODULE Cap; (* CAP of a character that is not a lower-case letter changes it *)
IMPORT Out;
CONST seven = CAP("7");                    (* folded *)
VAR c: CHAR;
BEGIN
  Out.Int(ORD(seven), 0); Out.String(" (expected 55, ORD of 7)"); Out.Ln;
  c := "{"; c := CAP(c);                   (* at run time *)
  Out.Char(c); Out.String(" (expected {)"); Out.Ln;
  c := "A"; c := CAP(c); Out.Char(c); Out.String(" (expected A)"); Out.Ln;
  c := "z"; c := CAP(c); Out.Char(c); Out.String(" (expected Z)"); Out.Ln
END Cap.
```

With voc at `master`:

```
$ voc -O2 Cap.Mod -m
Cap.Mod  Compiling Cap.  Main program.  746 chars.
$ ./Cap
23 (expected 55, ORD of 7)
[ (expected {)
A (expected A)
Z (expected Z)
(exit status 0)
```

## Cause and fix

__CAP cleared bit 5 (ch & 0x5F), so CAP("7") was 17X, CAP("{") "[",
CAP("`") "@", and CAP of 0E9X (Latin-1 e acute) "I". The compiler folds
a constant CAP with its own __CAP, so constants were wrong too. Now a
lower-case letter a..z becomes upper case and any other character is
left as it is.

The scanner's identifier test uses CAP; with the old __CAP it took the
bytes 0C1X..0DAX and 0E1X..0FAX as letters, which it now does not.

With the fix:

```
$ ./Cap
55 (expected 55, ORD of 7)
{ (expected {)
A (expected A)
Z (expected Z)
(exit status 0)
```

The fix is `patches/0009-CAP-changes-only-lower-case-letters.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
