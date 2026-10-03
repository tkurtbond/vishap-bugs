MODULE TextsFix; (* Texts.WriteRealFix drops decimals, and goes wrong past 9 digits *)
IMPORT Texts, Out;
VAR W: Texts.Writer; T: Texts.Text; R: Texts.Reader; ch: CHAR; x: REAL;
PROCEDURE F(x: REAL; n, k: INTEGER; expected: ARRAY OF CHAR);
BEGIN (* each line is written out at once, before the next WriteRealFix *)
  Texts.WriteString(W, "["); Texts.WriteRealFix(W, x, n, k); Texts.WriteString(W, "] (expected [");
  Texts.WriteString(W, expected); Texts.WriteString(W, "])");
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO Out.Char(ch); Texts.Read(R, ch) END; Out.Ln
END F;
BEGIN
  Texts.OpenWriter(W);
  F(3.25, 8, 2, "    3.25");
  F(1234.5, 12, 6, " 1234.500000");
  F(123456.0, 12, 4, " 123456.0000");
  F(0.0006, 8, 3, "   0.001");
  F(0.0004, 8, 3, "   0.000");
  F(0.6, 4, 0, "  1.");
  F(-0.125, 8, 2, "   -0.13");
  F(9.9999, 8, 2, "   10.00");
  x := 1.5E6; x := x * 1.0E6; F(x, 18, 1, "   1500000030000.0");  (* REAL 1500000026624, 9 digits *)
  x := 1.0E5; x := x * x; F(x, 16, 2, "  10000000000.00")      (* 1.0E10, made at run time *)
END TextsFix.
