# In.Name is not implemented

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`In.Name` stops the program with `HALT(99)` ("Not implemented").

## Reproducer

`InName.Mod`:

```oberon
MODULE InName; (* In.Name is not implemented *)
IMPORT In, Out;
VAR n: ARRAY 64 OF CHAR;
BEGIN
  In.Name(n); Out.String(n); Out.String(" (expected dir/file.txt)"); Out.Ln
END InName.
```

With voc at `master`:

```
$ voc -O2 InName.Mod -m
InName.Mod  Compiling InName.  Main program.  514 chars.
$ printf 'dir/file.txt\n' | ./InName
Terminated by Halt(99). 
(exit status 99)
```

## Cause and fix

It stopped the program with HALT(99), "Not implemented". It now reads
the characters up to the next blank or control character, Oakwood's
"name ... according to the file name format of the underlying operating
system (e.g. lib/My.Mod under Unix)", and sets Done to whether there was
one that fit in the array.

With the fix:

```
$ printf 'dir/file.txt\n' | ./InName
dir/file.txt (expected dir/file.txt)
(exit status 0)
```

The fix is `patches/0027-Implement-In.Name.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
