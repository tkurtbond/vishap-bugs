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
