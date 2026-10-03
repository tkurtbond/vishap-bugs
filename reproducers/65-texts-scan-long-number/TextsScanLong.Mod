MODULE TextsScanLong; (* Texts.Scan of a number of 32 digits or more *)
IMPORT Texts, Out;
VAR T: Texts.Text; W: Texts.Writer; S: Texts.Scanner; i: INTEGER;
BEGIN
  Texts.OpenWriter(W);
  Texts.WriteString(W, "3.14159265358979323846264338327950288 ");
  FOR i := 1 TO 300 DO Texts.Write(W, "1") END;     (* an integer of 300 digits *)
  Texts.WriteString(W, " next");
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenScanner(S, T, 0);
  Texts.Scan(S); Out.String("class "); Out.Int(S.class, 0);
  Out.String(" (expected 4, a REAL)"); Out.Ln;
  Texts.Scan(S); Out.String("class "); Out.Int(S.class, 0);
  Out.String(" (expected 0, Inval: too long for any integer)"); Out.Ln;
  Texts.Scan(S); Out.String("class "); Out.Int(S.class, 0); Out.Char(" "); Out.String(S.s);
  Out.String(" (expected 1 next)"); Out.Ln
END TextsScanLong.
