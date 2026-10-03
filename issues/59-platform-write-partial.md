# Platform.Write loses what a partial write leaves

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Platform.Write` makes one `write(2)` call and reports success if it
does not fail, though `write` may write fewer bytes than asked, to a pipe
or when a signal arrives. The rest is lost without an error. `Out`,
`Files` and `Console` write through `Platform.Write`.

## Reproducer

`WritePartial.Mod`:

```oberon
MODULE WritePartial; (* Platform.Write is a single write(2): a partial one is lost *)
IMPORT SYSTEM, Platform;
CONST N = 1000000;
VAR buf: POINTER TO ARRAY N OF CHAR; i: LONGINT; res: Platform.ErrorCode;
PROCEDURE -AAincludeSignal "#include <signal.h>";
PROCEDURE -AAincludeUnistd "#include <unistd.h>";
PROCEDURE -catch "struct sigaction sa = {0}; sa.sa_handler = (void (*)(int))WritePartial_Handler; sigaction(SIGALRM, &sa, 0); alarm(1)";
PROCEDURE Handler(signal: SYSTEM.INT32); (* only so that the signal does not end the program *)
END Handler;

BEGIN
  NEW(buf); FOR i := 0 TO N - 1 DO buf[i] := "x" END;
  catch;                   (* a signal arrives while the reader is not yet reading *)
  res := Platform.Write(Platform.StdOut, SYSTEM.ADR(buf^), N);
  IF res # 0 THEN Platform.Exit(1) END
END WritePartial.
```

With voc at `master`:

```
$ voc -O2 WritePartial.Mod -m
WritePartial.Mod  Compiling WritePartial.  Main program.  1169 chars.
$ ./WritePartial | (sleep 2; wc -c)
65536
(exit status 0)
```

## Cause and fix

Write (on Unix) made one write(2) call and returned 0 if it did not
fail, though write may write fewer bytes than asked: to a pipe or a
socket, or when a signal arrives after some bytes are written. The rest
was lost, unreported: one Platform.Write of 1000000 bytes to a pipe whose
reader started a second later wrote 65536 when a SIGALRM arrived in
between. Out, Files and Console write through Platform.Write.

Write now calls write until all of the bytes are written, and calls it
again when it is interrupted by a signal before writing anything
(EINTR). WriteCount, which reports how many bytes one call wrote, is
unchanged.

With the fix:

```
$ ./WritePartial | (sleep 2; wc -c)
1000000
(exit status 0)
```

The fix is `patches/0059-Platform.Write-write-all-of-the-bytes.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
