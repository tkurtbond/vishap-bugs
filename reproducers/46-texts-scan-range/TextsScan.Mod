MODULE TextsScan; (* Texts.Scan: a number with a large exponent stops the program (HALT(40)) *)
IMPORT Texts, Out;
VAR W: Texts.Writer; T: Texts.Text; S: Texts.Scanner;
PROCEDURE Try(text, expected: ARRAY OF CHAR);
BEGIN
  NEW(T); Texts.Open(T, ""); Texts.WriteString(W, text); Texts.Append(T, W.buf);
  Texts.OpenScanner(S, T, 0); Texts.Scan(S);
  Out.String(text); Out.String(": ");
  IF S.class = 4 THEN Out.Real(S.x, 15) ELSIF S.class = 5 THEN Out.LongReal(S.y, 24) ELSE Out.String("class "); Out.Int(S.class, 0) END;
  Out.String(" (expected "); Out.String(expected); Out.String(")"); Out.Ln
END Try;
BEGIN
  Texts.OpenWriter(W);
  Try("0.001D310", "about 1.0D+307");
  Try("1000.0D-310", "about 1.0D-307");
  Try("1.0D309", "Infinity");
  Try("1.0E39", "Infinity");
  Try("0.0D400", "0.0")
END TextsScan.
