# Texts.Save and Copy stop with a NIL access on an element that is not copied

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Texts.Save`, and `Texts.Copy` of a buffer, copy each element by sending
it a `CopyMsg`. If the element's handler makes no copy, a NIL goes into the
buffer and the program stops with a NIL access.

## Reproducer

`TextsCopyElem.Mod`:

```oberon
MODULE TextsCopyElem; (* copying an element whose handler does not copy it *)
IMPORT Texts, Out;
TYPE Elem = POINTER TO RECORD (Texts.ElemDesc) END;
VAR W: Texts.Writer; T: Texts.Text; B: Texts.Buffer; e: Elem;
  R: Texts.Reader; ch: CHAR; n: LONGINT;
PROCEDURE Handle(e: Texts.Elem; VAR msg: Texts.ElemMsg); (* answers no message *)
END Handle;
BEGIN
  NEW(e); e.W := 0; e.H := 0; e.handle := Handle;
  Texts.OpenWriter(W); Texts.WriteString(W, "ab"); Texts.WriteElem(W, e); Texts.WriteString(W, "cd");
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  NEW(B); Texts.OpenBuf(B); Texts.Save(T, 0, T.len, B);    (* copies the element: none comes back *)
  Texts.Append(T, B);
  n := 0; Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO INC(n); Texts.Read(R, ch) END;
  Out.Int(T.len, 0); Out.String(" long, read "); Out.Int(n, 0);
  Out.String(" (expected 9 long, the element left out of the copy; read 9)"); Out.Ln
END TextsCopyElem.
```

With voc at `master`:

```
$ voc -O2 TextsCopyElem.Mod -m
TextsCopyElem.Mod  Compiling TextsCopyElem.  Main program.  2646 chars.
$ ./TextsCopyElem
Terminated by Halt(-10). NIL access.
(exit status 246)
```

## Cause and fix

CloneElem asks an element's handler for a copy (a CopyMsg) and returns
msg.e, NIL when the handler answers no CopyMsg. Save and Copy linked that
NIL into the buffer, so a Save of a text with such an element, or a Copy
of a buffer holding one, stopped the program with a NIL access, then or
on the next use of the buffer.

Save and Copy now leave out an element whose handler makes no copy, and
the buffer's length counts only what was copied.

With the fix:

```
$ ./TextsCopyElem
9 long, read 9 (expected 9 long, the element left out of the copy; read 9)
(exit status 0)
```

The fix is `patches/0051-Texts.Save-and-Copy-an-element-that-is-not-copied-is.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
