# Oberon.Par cuts command-line arguments to 255 characters

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Oberon` copies each command-line argument into an
`ARRAY 256 OF CHAR` on its way to `Oberon.Par.text`, so an argument of
256 characters or more is cut.

## Reproducer

`LongParams.Mod`:

```oberon
MODULE LongParams; (* Oberon.Par of a command-line argument of 256 characters or more *)
IMPORT Oberon, Out;
BEGIN
  Out.Int(Oberon.Par.text.len, 0);
  Out.String(" characters (expected 301: the argument and a blank)"); Out.Ln
END LongParams.
```

With voc at `master`:

```
$ voc -O2 LongParams.Mod -m
LongParams.Mod  Compiling LongParams.  Main program.  506 chars.
$ ./LongParams "$(printf '%0300d' 0)"
256 characters (expected 301: the argument and a blank)
(exit status 0)
```

## Cause and fix

PopulateParams copied each command-line argument into an ARRAY 256 OF
CHAR before writing it into Oberon.Par.text, so an argument of 256
characters or more was cut to 255: with an argument of 300 characters,
Par.text was 256 characters long, not 301.

PopulateParams now writes each argument straight from argv, stopping
where WriteString stopped, at the first character below " ".

With the fix:

```
$ ./LongParams "$(printf '%0300d' 0)"
301 characters (expected 301: the argument and a blank)
(exit status 0)
```

The fix is `patches/0063-Oberon.Par-command-line-arguments-of-any-length.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
