MODULE SinCos; (* Math.sincos and MathL.sincos give a cosine that is never negative *)
IMPORT Math, MathL, Out;
VAR s, c: REAL; sl, cl: LONGREAL;
BEGIN
  Math.sincos(2.0, s, c);
  Out.String("Math.sincos(2.0):   cos "); Out.Real(c, 14); Out.String(" (expected "); Out.Real(Math.cos(2.0), 14); Out.String(")"); Out.Ln;
  MathL.sincos(2.0D0, sl, cl);
  Out.String("MathL.sincos(2.0):  cos "); Out.LongReal(cl, 23); Out.String(" (expected "); Out.LongReal(MathL.cos(2.0D0), 23); Out.String(")"); Out.Ln
END SinCos.
