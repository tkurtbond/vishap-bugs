# In.Real and In.LongReal read the rest of the line, cut at 15 characters

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`In.LongReal` reads the rest of the line into a 16-character buffer: a
number longer than 15 characters is cut, and the rest is left for the next
read; a second number on the same line is lost; and `Done` is TRUE whatever
the line held.

## Reproducer

`InReal.Mod`:

```oberon
MODULE InReal; (* In.LongReal: a line longer than 15 characters, and two numbers on a line *)
IMPORT In, Out;
VAR x, y: LONGREAL;
BEGIN
  In.LongReal(x); Out.LongReal(x, 0); Out.String(" (expected 3.14159265358979, as Out.LongReal prints it)"); Out.Ln;
  In.LongReal(x); In.LongReal(y);
  Out.LongReal(x, 0); Out.String(" "); Out.LongReal(y, 0); Out.String(" (expected 1.5 2.5)"); Out.Ln;
  In.LongReal(x); IF In.Done THEN Out.String("Done after abc (expected FALSE)") ELSE Out.String("not Done after abc") END; Out.Ln
END InReal.
```

With voc at `master`:

```
$ voc -O2 InReal.Mod -m
InReal.Mod  Compiling InReal.  Main program.  914 chars.
$ printf '3.14159265358979323846\n1.5 2.5\nabc\n' | ./InReal
3.1415926535897D+000 (expected 3.14159265358979, as Out.LongReal prints it)
9.323846D+006 1.5D+000 (expected 1.5 2.5)
Done after abc (expected FALSE)
(exit status 0)
```

## Cause and fix

They read the rest of the line into a 16 character array and converted
that: a number of more than 15 characters was cut short, the characters
after the 15th were left to the next read, a second number on the line
was lost, and Done was TRUE whatever the line held (it was Line's). They
now read one real constant, Oakwood's format with a sign, set Done to
whether there was one, and leave the input after it.

With the fix:

```
$ printf '3.14159265358979323846\n1.5 2.5\nabc\n' | ./InReal
3.14159265358979D+000 (expected 3.14159265358979, as Out.LongReal prints it)
1.5D+000 2.5D+000 (expected 1.5 2.5)
not Done after abc
(exit status 0)
```

The fix is `patches/0026-In.Real-and-LongReal-read-one-number-and-set-Done.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
