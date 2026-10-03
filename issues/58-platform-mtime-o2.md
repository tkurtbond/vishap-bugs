# Platform.MTimeAsClock (Files.GetDate) reads past its LONGINT under -O2

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Under `-O2`, `Platform.MTimeAsClock`, which `Files.GetDate` calls,
passes `localtime` the address of a 4-byte `LONGINT` as a `time_t *`, so
`localtime` reads 4 bytes beyond it. On Linux they happened to be 0 and
the date was right; on FreeBSD amd64 and OpenBSD i386 `localtime` returned
NULL and `Files.GetDate` stopped the program with a NIL access.

## Reproducer

`FileDate.Mod`:

```oberon
MODULE FileDate; (* Files.GetDate under -O2, where LONGINT has 4 bytes *)
IMPORT Files, Platform, Out;
VAR f: Files.File; t, d, ft, fd: LONGINT;
PROCEDURE Date(t, d: LONGINT);
BEGIN
  Out.Int(2000 + d DIV 512, 0); Out.Char("-"); Out.Int(d DIV 32 MOD 16, 2); Out.Char("-"); Out.Int(d MOD 32, 2);
  Out.Char(" "); Out.Int(t DIV 4096, 2); Out.Char(":"); Out.Int(t DIV 64 MOD 64, 2)
END Date;
BEGIN
  f := Files.New("date.txt"); Files.Register(f);
  Platform.GetClock(t, d); f := Files.Old("date.txt"); Files.GetDate(f, ft, fd);
  Out.String("now                "); Date(t, d); Out.Ln;
  Out.String("file's date        "); Date(ft, fd); Out.String(" (expected the same, to the minute)"); Out.Ln
END FileDate.
```

With voc at `master`:

```
$ voc -O2 FileDate.Mod -m
FileDate.Mod  Compiling FileDate.  Main program.  1402 chars.
$ ./FileDate
now                2026-10- 3 16:17
file's date        2026-10- 3 16:17 (expected the same, to the minute)
(exit status 0)
```

On FreeBSD 15.1-RELEASE amd64, clang 19.1.7, voc built there at the same commits:

```
$ voc -O2 FileDate.Mod -m
FileDate.Mod  Compiling FileDate.  Main program.  1405 chars.
$ ./FileDate
Terminated by Halt(-10). NIL access.
(exit status 246)
```

## Cause and fix

sectotm passed localtime the address of its LONGINT argument, cast to
time_t *. Under -O2 a LONGINT has 4 bytes and time_t 8, so localtime read
4 bytes beyond the value. MTimeAsClock passes the mtime field of a
FileIdentity, the last field of the record, so Files.GetDate read
whatever followed the record: on FreeBSD amd64 and OpenBSD i386 that
gave a time so far off that localtime returned NULL, and Files.GetDate
stopped the program with a NIL access. (GetClock passes tv.tv_sec, a
time_t, so it was not affected.)

sectotm now copies its argument into a time_t and passes that.

With the fix:

```
$ ./FileDate
now                2026-10- 3 16:17
file's date        2026-10- 3 16:17 (expected the same, to the minute)
(exit status 0)
```

On FreeBSD, with the fix:

```
$ ./FileDate
now                2026-10- 3 15:59
file's date        2026-10- 3 15:59 (expected the same, to the minute)
(exit status 0)
```

The fix is `patches/0058-Platform-localtime-of-a-time-held-in-a-LONGINT.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
