MODULE TextsSubnormal; (* Texts writes a subnormal number as 0 *)
IMPORT SYSTEM, Texts, Out;
VAR W: Texts.Writer; T: Texts.Text; R: Texts.Reader; ch: CHAR;
  x: REAL; y: LONGREAL; i: SYSTEM.INT32; h: HUGEINT;
BEGIN
  Texts.OpenWriter(W);
  i := 1; x := SYSTEM.VAL(REAL, i);  (* 2^-149 *)
  Texts.WriteReal(W, x, 14); Texts.WriteString(W, " (expected  1.401298E-45)"); Texts.WriteLn(W);
  h := 1; y := SYSTEM.VAL(LONGREAL, h);  (* 2^-1074 *)
  Texts.WriteLongReal(W, y, 23); Texts.WriteString(W, " (expected  4.94065645841247D-324)"); Texts.WriteLn(W);
  y := 0.0D0; Texts.WriteLongReal(W, y, 23); Texts.WriteString(W, " (expected  0, as before)"); Texts.WriteLn(W);
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO IF ch = 0DX THEN Out.Ln ELSE Out.Char(ch) END; Texts.Read(R, ch) END; Out.Ln
END TextsSubnormal.
