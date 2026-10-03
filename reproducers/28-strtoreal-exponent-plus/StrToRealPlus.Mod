MODULE StrToRealPlus; (* Strings.StrToLongReal and StrToReal ignore an exponent with a "+" *)
IMPORT Strings, Out;
VAR d: LONGREAL; r: REAL;
BEGIN
  Strings.StrToLongReal("2.5E+2", d); Out.LongReal(d, 0); Out.String(" (expected 250)"); Out.Ln;
  Strings.StrToReal("2.5E+2", r); Out.Real(r, 0); Out.String(" (expected 250)"); Out.Ln
END StrToRealPlus.
