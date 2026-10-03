# Files.Rename of an open file leaves the open File with the old name: Halt(99) later

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

After `Files.Rename` of a file the program has open, the open `File` keeps
the old name (the TODO in `Rename`). Registering a new file under the new
name then tries to rename the open file by its old, gone name and stops the
program with "Couldn't rename previous version of file being registered",
`Halt(99)`.

## Reproducer

`FilesRenameOpen.Mod`:

```oberon
MODULE FilesRenameOpen; (* Files.Rename of a file the program has open *)
IMPORT Files, Out;
VAR f, g: Files.File; r: Files.Rider; res: INTEGER;

PROCEDURE Make(name: ARRAY OF CHAR): Files.File;
  VAR f: Files.File;
BEGIN f := Files.New(name); Files.Set(r, f, 0); Files.Write(r, "x"); Files.Register(f); RETURN f
END Make;

BEGIN
  g := Make("b.txt");                          (* g is still open *)
  Files.Rename("b.txt", "c.txt", res);
  Out.String("Rename of an open file: res = "); Out.Int(res, 0); Out.Ln;
  f := Make("c.txt");                          (* replaces the file g has open *)
  Out.String("c.txt made again"); Out.Ln
END FilesRenameOpen.
```

With voc at `master`:

```
$ voc -O2 FilesRenameOpen.Mod -m
FilesRenameOpen.Mod  Compiling FilesRenameOpen.  Main program.  1413 chars.
$ ./FilesRenameOpen
Rename of an open file: res = 0

-- Couldn't rename previous version of file being registered: b.txt, f.fd = 3, errcode = 2
Terminated by Halt(99). 
(exit status 99)
```

## Cause and fix

A File open under the old name kept it (the TODO in Rename). When a file
of the new name was registered later, Deregister found the open File by
device and inode and renamed it by the old name, which no longer
existed: "Couldn't rename previous version of file being registered",
Halt(99). Rename now gives such a File the new name.

With the fix:

```
$ ./FilesRenameOpen
Rename of an open file: res = 0
c.txt made again
(exit status 0)
```

The fix is `patches/0017-Files.Rename-gives-an-open-File-of-the-renamed-file-.patch`, a `git format-patch` of one commit.

It needs these applied first: patch 0015 (Files keeps relative names and later renames by them from another directory: Halt(99)).

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
