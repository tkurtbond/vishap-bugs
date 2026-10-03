# Texts.Close traps on a file name of 60 characters or more

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Texts.Close` makes the backup file's name, the name followed by
`.Bak`, in an `ARRAY 64 OF CHAR`: a name of 60 characters or more, which
`Files` takes, stops the program with an index out of range.

## Reproducer

`TextsCloseName.Mod`:

```oberon
MODULE TextsCloseName; (* Texts.Close of a file name of 60 characters or more *)
IMPORT Texts, Out;
VAR T: Texts.Text;
BEGIN
  NEW(T); Texts.Open(T, "");
  Texts.Close(T, "a-file-name-of-sixty-characters-which-is-not-long-at-all.txt");
  Out.String("closed (expected)"); Out.Ln
END TextsCloseName.
```

With voc at `master`:

```
$ voc -O2 TextsCloseName.Mod -m
TextsCloseName.Mod  Compiling TextsCloseName.  Main program.  740 chars.
$ ./TextsCloseName
Terminated by Halt(-2). Index out of range.
(exit status 254)
```

## Cause and fix

Close made the backup file's name, name + ".Bak", in an ARRAY 64 OF CHAR,
so a name of 60 characters or more stopped the program with an index
out of range, though Files takes names of up to 255 characters.

The backup name now has room for any name Files takes, and the length of
the name is found within its array.

With the fix:

```
$ ./TextsCloseName
closed (expected)
(exit status 0)
```

The fix is `patches/0052-Texts.Close-file-names-of-any-length-Files-takes.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
