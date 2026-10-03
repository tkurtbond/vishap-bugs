# Texts: storing a text loaded from a file stops with a NIL access

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

A text opened from an Oberon text file (one that `Texts.Close` or
`Texts.Store` wrote) has no fonts: every run's `fnt` is NIL. Storing it
again with `Texts.Close` or `Texts.Store`, or inserting into it where runs
are merged, stops the program with a NIL access.

## Reproducer

`TextsLoadFonts.Mod`:

```oberon
MODULE TextsLoadFonts; (* a text loaded from a file has no fonts: Store stops the program *)
IMPORT Texts, Out;
VAR W: Texts.Writer; T: Texts.Text;
BEGIN
  Texts.OpenWriter(W); Texts.WriteString(W, "hello"); Texts.WriteLn(W);
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.Close(T, "a.text");                 (* stored as an Oberon text *)
  NEW(T); Texts.Open(T, "a.text");          (* loaded: runs with fnt = NIL *)
  Texts.Close(T, "b.text");                 (* Store compares u.fnt.name *)
  Out.String("stored again (expected)"); Out.Ln
END TextsLoadFonts.
```

With voc at `master`:

```
$ voc -O2 TextsLoadFonts.Mod -m
TextsLoadFonts.Mod  Compiling TextsLoadFonts.  Main program.  1175 chars.
$ ./TextsLoadFonts
Terminated by Halt(-10). NIL access.
(exit status 246)
```

## Cause and fix

Load0 read each run's font number and the font names, but the line that
gave the run its font was commented out, so every run of a text loaded
from an Oberon text file had fnt = NIL. Store and Merge compare
u.fnt.name, so storing such a text again, with Texts.Close or
Texts.Store, or inserting into it, stopped the program with a NIL access,
and a Reader's fnt was NIL.

Load0 now sets the run's font to the one the file names, as Store wrote
it.

With the fix:

```
$ ./TextsLoadFonts
stored again (expected)
(exit status 0)
```

The fix is `patches/0049-Texts-a-loaded-text-s-runs-have-their-fonts.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
