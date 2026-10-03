# VT100.SetAttr cuts its argument at 13 characters

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`VT100.SetAttr("38;5;123;48;5;45m")` sends `ESC[38;5;123;48;5;` without the
final `m`, so the terminal takes the following text as part of the
sequence.

## Reproducer

`VT100SetAttr.Mod`:

```oberon
MODULE VT100SetAttr; (* SetAttr cuts its argument at 13 characters *)
IMPORT VT100, Out;
BEGIN
  VT100.SetAttr("38;5;123;48;5;45m"); Out.String(" (expected ESC[38;5;123;48;5;45m)"); Out.Ln;
  VT100.SetAttr("0m")
END VT100SetAttr.
```

With voc at `master`:

```
$ voc -O2 VT100SetAttr.Mod -m
VT100SetAttr.Mod  Compiling VT100SetAttr.  Main program.  531 chars.
$ ./VT100SetAttr
[38;5;123;48;5; (expected ESC[38;5;123;48;5;45m)
(exit status 0)
```

## Cause and fix

SetAttr built CSI and attr in an ARRAY 16 OF CHAR, so attr was cut at
13 characters (and, with Strings.Append's own bug, left without a 0X):
SetAttr("38;5;123;48;5;45m") sent ESC[38;5;123;48;5; without the
final m, and the terminal took the text after it as part of the
sequence. It now writes CSI and attr one after the other.

With the fix:

```
$ ./VT100SetAttr
[38;5;123;48;5;45m (expected ESC[38;5;123;48;5;45m)
(exit status 0)
```

The fix is `patches/0035-VT100.SetAttr-writes-all-of-its-argument.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
