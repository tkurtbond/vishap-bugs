MODULE ArcsinhLarge; (* arcsinh and arccosh of a large argument *)
IMPORT Math, MathL, Out;
VAR x: REAL; y: LONGREAL;
BEGIN
  x := 1.0E10; x := x * x; Math.ClearError;
  Out.Real(Math.arcsinh(x), 16); Out.String(" error "); Out.Int(Math.err, 0);
  Out.String(" (expected about 4.6745E+01, error 0)"); Out.Ln;
  Math.ClearError;
  Out.Real(Math.arccosh(x), 16); Out.String(" error "); Out.Int(Math.err, 0);
  Out.String(" (expected about 4.6745E+01, error 0)"); Out.Ln;
  y := 1.0D100; y := y * y; Math.ClearError;
  Out.LongReal(MathL.arcsinh(y), 24); Out.String(" error "); Out.Int(Math.err, 0);
  Out.String(" (expected 4.6121016577936911D+002, error 0)"); Out.Ln
END ArcsinhLarge.
