# Files keeps relative names and later renames by them from another directory: Halt(99)

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Files.New` and `Files.Old` store the name as given. When the same file is
registered again later, `Files` renames the open `File` by that stored name,
resolved against the directory current then; after a change of directory
this fails with ENOENT and the program stops with "Couldn't rename previous
version of file being registered" and `Halt(99)`.

## Reproducer

Run in a directory with a subdirectory `sub` (`mkdir -p sub`).

`FilesRelative.Mod`:

```oberon
MODULE FilesRelative; (* Files keeps a name relative to the directory current at New/Old *)
(* Run in a directory with a subdirectory "sub": mkdir -p sub *)
IMPORT Files, Platform, Out;
VAR f, g: Files.File; r: Files.Rider; res: INTEGER; dir: ARRAY 4 OF CHAR;
BEGIN
  f := Files.New("sub/a.txt"); Files.Set(r, f, 0); Files.Write(r, "1"); Files.Register(f);
  dir := "sub"; res := Platform.Chdir(dir);
  (* "a.txt" here is the file f still refers to; registering it renames
     the old version by f's name, "sub/a.txt", now relative to "sub" *)
  g := Files.New("a.txt"); Files.Set(r, g, 0); Files.Write(r, "2"); Files.Register(g);
  Out.String("ok"); Out.Ln
END FilesRelative.
```

With voc at `master`:

```
$ voc -O2 FilesRelative.Mod -m
FilesRelative.Mod  Compiling FilesRelative.  Main program.  1294 chars.
$ ./FilesRelative

-- Couldn't rename previous version of file being registered: sub/a.txt, f.fd = 3, errcode = 2
Terminated by Halt(99). 
(exit status 99)
```

## Cause and fix

New and Old stored the name as given, relative to the directory current
then. When the same file was registered again later (Deregister finds
it by device and inode) Files renamed the open File by that stored name,
resolved against the directory current at that time: after a change of
directory the rename failed with ENOENT and the program stopped with
"Couldn't rename previous version of file being registered" and
Halt(99). Old also stored the name it was asked for, not the path where
the search path found it. Both now store the whole path (from
Platform.CWD), as GetTempName already did for temporary files. GetName
now gives the whole path.

With the fix:

```
$ ./FilesRelative
ok
(exit status 0)
```

The fix is `patches/0015-Files-keep-each-file-s-name-as-a-whole-path.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
