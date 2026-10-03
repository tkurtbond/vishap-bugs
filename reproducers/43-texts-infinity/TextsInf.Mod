MODULE TextsInf; (* Texts writes an infinity as "NaN" *)
IMPORT Texts, Oberon, Out;
VAR W: Texts.Writer; T: Texts.Text; R: Texts.Reader; ch: CHAR; x, zero: REAL; y: LONGREAL;
BEGIN
  Texts.OpenWriter(W); zero := 0.0;
  x := 1.0 / zero; y := x;
  Texts.WriteReal(W, x, 12); Texts.WriteString(W, " (expected  Infinity)"); Texts.WriteLn(W);
  Texts.WriteReal(W, -x, 12); Texts.WriteString(W, " (expected -Infinity)"); Texts.WriteLn(W);
  Texts.WriteLongReal(W, y, 12); Texts.WriteString(W, " (expected  Infinity)"); Texts.WriteLn(W);
  Texts.WriteRealFix(W, x, 12, 2); Texts.WriteString(W, " (expected  Infinity)"); Texts.WriteLn(W);
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO IF ch = 0DX THEN Out.Ln ELSE Out.Char(ch) END; Texts.Read(R, ch) END
END TextsInf.
