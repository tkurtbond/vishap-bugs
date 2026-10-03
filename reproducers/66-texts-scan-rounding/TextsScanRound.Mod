MODULE TextsScanRound; (* Texts.Scan of real numbers: are they correctly rounded? *)
IMPORT SYSTEM, Texts, Out;
VAR T: Texts.Text; W: Texts.Writer; S: Texts.Scanner; i: SYSTEM.INT32; h: SYSTEM.INT64;
PROCEDURE Next(expected: ARRAY OF CHAR);
BEGIN
  Texts.Scan(S);
  IF S.class = Texts.Real THEN i := SYSTEM.VAL(SYSTEM.INT32, S.x); Out.Hex(i, 8)
  ELSE h := SYSTEM.VAL(SYSTEM.INT64, S.y); Out.Hex(h, 16)
  END;
  Out.String(" (expected "); Out.String(expected); Out.Char(")"); Out.Ln
END Next;
BEGIN
  Texts.OpenWriter(W); Texts.WriteString(W, "1.06E7 0.3D0 6.02214076D23");
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenScanner(S, T, 0);
  Next("4B21BE40, 10600000.0");
  Next("3FD3333333333333");
  Next("44DFE185CA57C517")
END TextsScanRound.
