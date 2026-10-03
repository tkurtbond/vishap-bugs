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
