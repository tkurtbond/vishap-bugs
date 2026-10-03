MODULE RealExponent; (* REAL literals with exponent 38, LONGREAL with 308, are "too large" *)
IMPORT Out;
VAR r: REAL; d: LONGREAL;
BEGIN
  r := 3.4E38;  Out.Real(r, 0); Out.Ln;      (* MAX(REAL) is about 3.40282E38 *)
  d := 1.7D308; Out.LongReal(d, 0); Out.Ln   (* MAX(LONGREAL) is about 1.79769D308 *)
END RealExponent.
