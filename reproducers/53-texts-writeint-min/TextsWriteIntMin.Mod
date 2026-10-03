MODULE TextsWriteIntMin; (* Texts.WriteInt of MIN(SYSTEM.INT64) ignores the width *)
IMPORT SYSTEM, Texts, Out;
VAR W: Texts.Writer; T: Texts.Text; R: Texts.Reader; ch: CHAR;
BEGIN
  Texts.OpenWriter(W);
  Texts.Write(W, "["); Texts.WriteInt(W, MIN(SYSTEM.INT64), 24); Texts.Write(W, "]");
  Texts.WriteString(W, " (expected [    -9223372036854775808])"); Texts.WriteLn(W);
  Texts.Write(W, "["); Texts.WriteInt(W, MIN(SYSTEM.INT64), 0); Texts.Write(W, "]");
  Texts.WriteString(W, " (expected [-9223372036854775808])");
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO IF ch = 0DX THEN Out.Ln ELSE Out.Char(ch) END; Texts.Read(R, ch) END; Out.Ln
END TextsWriteIntMin.
