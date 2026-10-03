# Strings.Append and Insert leave no 0X when the result is too long

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Oakwood requires a result too long for `dst` to be cut short so that `dst`
always ends with 0X. `Append` fills `dst` to its last element and leaves no
0X, and `Insert` leaves none either.

## Reproducer

`StringsOverflow.Mod`:

```oberon
MODULE StringsOverflow; (* Strings.Append and Insert: a result too long for dest *)
IMPORT Strings, Out;
VAR s: ARRAY 6 OF CHAR; i: INTEGER;
PROCEDURE Show(s: ARRAY OF CHAR);
  VAR i: INTEGER;
BEGIN i := 0;
  WHILE (i < LEN(s)) & (s[i] # 0X) DO Out.Char(s[i]); INC(i) END;
  IF i = LEN(s) THEN Out.String(" (no 0X)") END; Out.Ln
END Show;
BEGIN
  s := "abc"; Strings.Append("XYZ", s); Show(s);   (* expected abcXY, ended by 0X *)
  s := "abc"; Strings.Insert("XYZ", 1, s); Show(s)  (* expected aXYZb, ended by 0X *)
END StringsOverflow.
```

With voc at `master`:

```
$ voc -O2 StringsOverflow.Mod -m
StringsOverflow.Mod  Compiling StringsOverflow.  Main program.  1092 chars.
$ ./StringsOverflow
abcXYZ (no 0X)
aXYZbc (no 0X)
(exit status 0)
```

## Cause and fix

Oakwood: "If the size of dst is not large enough to hold the result of
the operation, the result is truncated so that dst is always terminated
with a 0X." Append filled dest to its last element and left no 0X, and
Insert, when the result did not fit, left none either and wrote the
inserted characters with no bound (an index trap, or a write past dest
without -x).

With the fix:

```
$ ./StringsOverflow
abcXY
aXYZb
(exit status 0)
```

The fix is `patches/0020-Strings.Append-and-Insert-cut-a-result-too-long-for-.patch`, a `git format-patch` of one commit.

It changes lines that patch 0018 (Strings.Insert at a position past the end does nothing) also changes, and is made to apply after it.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
