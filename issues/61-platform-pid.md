# Platform.PID is wrong under -O2, and temporary file names can collide

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Platform.PID` is an `INTEGER`, 16 bits under `-O2`, so a process id
above 32767 wraps. `Files` builds temporary file names from `PID`, and
writes no digits for a negative one, so two programs in one directory can
make the same temporary names.

## Reproducer

`Pid.Mod`:

```oberon
MODULE Pid; (* Platform.PID under -O2, where INTEGER has 2 bytes *)
IMPORT SYSTEM, Platform, Out;
PROCEDURE -AAincludeUnistd "#include <unistd.h>";
PROCEDURE -getpid(): LONGINT "(LONGINT)getpid()";
BEGIN
  IF Platform.PID = getpid() THEN Out.String("PID is the process id (expected)")
  ELSE Out.String("PID "); Out.Int(Platform.PID, 0); Out.String(", process id "); Out.Int(getpid(), 0);
    Out.String(" (expected the same)")
  END; Out.Ln
END Pid.
```

With voc at `master`:

```
$ voc -O2 Pid.Mod -m
Pid.Mod  Compiling Pid.  Main program.  736 chars.
$ ./Pid
PID -1171, process id 588653 (expected the same)
(exit status 0)
```

## Cause and fix

PID was an INTEGER, which under -O2 has 16 bits, while process ids run
to 4194304 on Linux and 99999 on FreeBSD and OpenBSD: a process with id
498041 had PID -26247. Files.GetTempName writes PID's digits into a
temporary file's name and wrote none for a negative PID, so two
programs whose ids differed by a multiple of 65536, or both had a
negative PID, made the same temporary names in a directory they shared.

PID is now a LONGINT (on Unix and on Windows), as is
oocFilesHost.ProcessId, which returns it. Files.GetTempName reads it into
a LONGINT and checks that the name has room for its 10 digits.

With the fix:

```
$ ./Pid
PID is the process id (expected)
(exit status 0)
```

The fix is `patches/0061-Platform.PID-a-LONGINT-which-holds-any-process-id.patch`, a `git format-patch` of one commit.

It changes lines that patch 0015 (Files keeps relative names and later renames by them from another directory: Halt(99)) also changes, and is made to apply after it.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
