# Platform.Delay returns early when a signal arrives

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Platform.Delay(ms)` makes one `nanosleep` call, which returns early
when a signal is caught, so the program sleeps less than `ms`.

## Reproducer

`DelaySignal.Mod`:

```oberon
MODULE DelaySignal; (* Platform.Delay returns early when a signal arrives *)
IMPORT SYSTEM, Platform, Out;
VAR start, ms: LONGINT;
PROCEDURE -AAincludeSignal "#include <signal.h>";
PROCEDURE -AAincludeUnistd "#include <unistd.h>";
PROCEDURE -catch "struct sigaction sa = {0}; sa.sa_handler = (void (*)(int))DelaySignal_Handler; sigaction(SIGALRM, &sa, 0); alarm(1)";
PROCEDURE Handler(signal: SYSTEM.INT32); (* only so that the signal does not end the program *)
END Handler;

BEGIN
  catch;                                  (* SIGALRM after 1 s *)
  start := Platform.Time(); Platform.Delay(3000); ms := Platform.Time() - start;
  IF ms >= 3000 THEN Out.String("slept 3 s or more") ELSE Out.String("slept "); Out.Int(ms DIV 100 * 100, 0); Out.String(" ms") END;
  Out.String(" (expected 3 s or more)"); Out.Ln
END DelaySignal.
```

With voc at `master`:

```
$ voc -O2 DelaySignal.Mod -m
DelaySignal.Mod  Compiling DelaySignal.  Main program.  1119 chars.
$ ./DelaySignal
slept 1000 ms (expected 3 s or more)
(exit status 0)
```

## Cause and fix

Delay made one nanosleep call, which returns early, with EINTR, when a
signal is caught: Platform.Delay(3000) returned after 1 s when a SIGALRM
arrived then. nanosleep reports the time left, and Delay dropped it.

Delay now calls nanosleep again with the time left until it has slept
the whole time.

With the fix:

```
$ ./DelaySignal
slept 3 s or more (expected 3 s or more)
(exit status 0)
```

The fix is `patches/0060-Platform.Delay-sleep-the-whole-time-when-a-signal-ar.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
