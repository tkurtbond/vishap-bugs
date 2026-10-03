# Strings.Extract into a small dest writes past its end

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Strings.Extract("abcdefgh", 1, 6, d)` with `d: ARRAY 4 OF CHAR` stops with an
index trap (or, without `-x`, writes past `d`): the part is not cut short to
leave room for the 0X.

## Reproducer

`StringsExtract.Mod`:

```oberon
MODULE StringsExtract; (* Strings.Extract into a dest too small for the part *)
IMPORT Strings, Out;
VAR d: ARRAY 4 OF CHAR;
BEGIN
  Strings.Extract("abcdefgh", 1, 6, d);
  Out.String(d); Out.String(" (expected bcd)"); Out.Ln
END StringsExtract.
```

With voc at `master`:

```
$ voc -O2 StringsExtract.Mod -m
StringsExtract.Mod  Compiling StringsExtract.  Main program.  580 chars.
$ ./StringsExtract
Terminated by Halt(-2). Index out of range.
(exit status 254)
```

## Cause and fix

Extract counted on to the length of the part and wrote its 0X there, past
the end of a dest too small for it: an index trap, or a write past dest
without -x. It also read source[LEN(source)] when the part ran to the end
of an unterminated source. Oakwood: "the result is truncated so that dst
is always terminated with a 0X."

With the fix:

```
$ ./StringsExtract
bcd (expected bcd)
(exit status 0)
```

The fix is `patches/0021-Strings.Extract-cuts-a-part-too-long-for-dest-to-end.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
