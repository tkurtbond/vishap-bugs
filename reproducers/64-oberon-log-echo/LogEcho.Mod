MODULE LogEcho; (* Oberon.Log echoes text that is deleted or changed, not only appended *)
IMPORT Oberon, Texts, Out;
VAR W: Texts.Writer;
BEGIN
  Texts.OpenWriter(W); Texts.WriteString(W, "appended"); Texts.WriteLn(W);
  Texts.Append(Oberon.Log, W.buf);
  Out.String("-- deleting pend:"); Out.Ln;
  Texts.Delete(Oberon.Log, 2, 6);
  Out.String("-- (expected nothing above this line)"); Out.Ln
END LogEcho.
