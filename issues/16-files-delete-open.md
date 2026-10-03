# Files.Delete of a file the program has open reports failure but deletes it

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Files.Delete` of a file that is still open returns `res = 2` although the
name is gone afterwards.

## Reproducer

`FilesDeleteOpen.Mod`:

```oberon
MODULE FilesDeleteOpen; (* Files.Delete of a file the program has open *)
IMPORT Files, Out;
VAR f: Files.File; r: Files.Rider; res: INTEGER;

PROCEDURE Make(name: ARRAY OF CHAR): Files.File;
  VAR f: Files.File;
BEGIN f := Files.New(name); Files.Set(r, f, 0); Files.Write(r, "x"); Files.Register(f); RETURN f
END Make;

BEGIN
  f := Make("a.txt");                          (* f is still open *)
  Files.Delete("a.txt", res);
  Out.String("Delete of an open file: res = "); Out.Int(res, 0); Out.String(" (expected 0)"); Out.Ln;
  IF Files.Old("a.txt") = NIL THEN Out.String("a.txt is gone") ELSE Out.String("a.txt is still there") END; Out.Ln
END FilesDeleteOpen.
```

With voc at `master`:

```
$ voc -O2 FilesDeleteOpen.Mod -m
FilesDeleteOpen.Mod  Compiling FilesDeleteOpen.  Main program.  1435 chars.
$ ./FilesDeleteOpen
Delete of an open file: res = 2 (expected 0)
a.txt is gone
(exit status 0)
```

## Cause and fix

Delete first deregisters the name: a File open under it is renamed to a
temporary name (deleted when the File is finalized). The unlink of the
name that follows then failed with ENOENT, so res was 2, though the name
was gone. res is now 0 when the name existed and is gone.

With the fix:

```
$ ./FilesDeleteOpen
Delete of an open file: res = 0 (expected 0)
a.txt is gone
(exit status 0)
```

The fix is `patches/0016-Files.Delete-of-an-open-file-reports-success.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
