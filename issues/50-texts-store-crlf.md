# Texts.Store writes CR LF of a plain text as two line ends

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Texts.Open` of a plain text file reads CR LF as one line end, but
`Texts.Store` (and so `Texts.Close`) writes it as CR CR: a file with CR LF
line ends, opened and closed, has twice as many lines when it is opened
again.

## Reproducer

`TextsCrLf.Mod`:

```oberon
MODULE TextsCrLf; (* Store writes CR LF of a plain text file as two line ends *)
IMPORT Files, Texts, Out;
VAR f: Files.File; r: Files.Rider; T: Texts.Text; R: Texts.Reader; ch: CHAR; n: INTEGER;
PROCEDURE Lines(T: Texts.Text): INTEGER;
  VAR n: INTEGER;
BEGIN n := 0; Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO IF ch = 0DX THEN INC(n) END; Texts.Read(R, ch) END;
  RETURN n
END Lines;
BEGIN
  f := Files.New("crlf.txt"); Files.Set(r, f, 0);
  Files.Write(r, "a"); Files.Write(r, 0DX); Files.Write(r, 0AX);
  Files.Write(r, "b"); Files.Write(r, 0DX); Files.Write(r, 0AX); Files.Register(f);
  NEW(T); Texts.Open(T, "crlf.txt");        (* a plain text: CR LF read as it is *)
  Texts.Close(T, "crlf.text");              (* stored as an Oberon text *)
  NEW(T); Texts.Open(T, "crlf.text");
  n := Lines(T); Out.Int(n, 0); Out.String(" line ends (expected 2)"); Out.Ln
END TextsCrLf.
```

With voc at `master`:

```
$ voc -O2 TextsCrLf.Mod -m
TextsCrLf.Mod  Compiling TextsCrLf.  Main program.  1973 chars.
$ ./TextsCrLf
4 line ends (expected 2)
(exit status 0)
```

## Cause and fix

A text opened from a plain text file reads CR LF as one CR (Read skips
the LF), but Store turned every LF of it into a CR, so CR LF was stored as
CR CR: a file with CR LF line ends, opened and stored with Texts.Close,
had twice as many lines when it was opened again.

Store now writes CR LF of a plain text piece as one CR, and LF alone as
CR as before. The lengths it writes, of the runs and of the text, leave
out the LFs dropped, so the positions of the elements after them stay
right.

With the fix:

```
$ ./TextsCrLf
2 line ends (expected 2)
(exit status 0)
```

The fix is `patches/0050-Texts.Store-CR-LF-in-a-plain-text-is-one-line-end.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
