MODULE ExpDenormal; (* exp of an argument whose result is a denormal number *)
IMPORT Math, MathL, Out;
BEGIN
  Math.ClearError;
  Out.Real(Math.exp(-90.0), 16); Out.String(" error "); Out.Int(Math.err, 0);
  Out.String(" (expected about 8.19E-40, error 0)"); Out.Ln;
  Math.ClearError;
  Out.LongReal(MathL.exp(-720.0D0), 24); Out.String(" error "); Out.Int(Math.err, 0);
  Out.String(" (expected about 2.03E-313, error 0)"); Out.Ln
END ExpDenormal.
