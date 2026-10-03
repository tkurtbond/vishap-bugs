# Files.ReadString and Files.ReadLine write past the end of the array

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Files.ReadString` and `Files.ReadLine` store every character of the value
with no bound, so a value longer than the array is an index trap (or, with
`-x` off, a write past it).

## Reproducer

`FilesReadString.Mod`:

```oberon
MODULE FilesReadString; (* Files.ReadString into an array too small for the string *)
IMPORT Files, Out;
VAR f: Files.File; r: Files.Rider; s: ARRAY 4 OF CHAR;
BEGIN
  f := Files.New("strings.dat"); Files.Set(r, f, 0);
  Files.WriteString(r, "abcdefgh"); Files.WriteString(r, "xy");
  Files.Register(f);
  Files.Set(r, f, 0);
  Files.ReadString(r, s); Out.String(s); Out.String(" (expected abc)"); Out.Ln;
  Files.ReadString(r, s); Out.String(s); Out.String(" (expected xy)"); Out.Ln
END FilesReadString.
```

`FilesReadLine.Mod`:

```oberon
MODULE FilesReadLine; (* Files.ReadLine into an array too small for the line *)
IMPORT Files, Out;
VAR f: Files.File; r: Files.Rider; s: ARRAY 4 OF CHAR;

PROCEDURE WriteLine(text: ARRAY OF CHAR);
  VAR i: INTEGER;
BEGIN i := 0; WHILE text[i] # 0X DO Files.Write(r, text[i]); INC(i) END; Files.Write(r, 0AX)
END WriteLine;

BEGIN
  f := Files.New("lines.txt"); Files.Set(r, f, 0);
  WriteLine("abcdefgh"); WriteLine("xy"); Files.Register(f);
  Files.Set(r, f, 0);
  Files.ReadLine(r, s); Out.String(s); Out.String(" (expected abc)"); Out.Ln;
  Files.ReadLine(r, s); Out.String(s); Out.String(" (expected xy)"); Out.Ln
END FilesReadLine.
```

With voc at `master`:

```
$ voc -O2 FilesReadString.Mod -m
FilesReadString.Mod  Compiling FilesReadString.  Main program.  1364 chars.
$ ./FilesReadString
Terminated by Halt(-2). Index out of range.
(exit status 254)
```

```
$ voc -O2 FilesReadLine.Mod -m
FilesReadLine.Mod  Compiling FilesReadLine.  Main program.  1651 chars.
$ ./FilesReadLine
Terminated by Halt(-2). Index out of range.
(exit status 254)
```

## Cause and fix

Both stored every character up to the 0X (or line feed) with no bound,
so a longer value was an index trap, or a write past x without -x. A
value too long for x is now cut short to end it with 0X, and the rest of
it is read and dropped, so the rider is after it as before.

With the fix:

```
$ ./FilesReadString
abc (expected abc)
xy (expected xy)
(exit status 0)
```

```
$ ./FilesReadLine
abc (expected abc)
xy (expected xy)
(exit status 0)
```

The fix is `patches/0023-Files.ReadString-and-ReadLine-stop-at-the-end-of-the.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
