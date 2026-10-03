MODULE OutExponent; (* Out.Real and Out.LongReal: the exponent misses a carry from rounding *)
IMPORT SYSTEM, Out;
VAR r: REAL; d: LONGREAL; bits: SYSTEM.INT64;
BEGIN
  r := 1.0E37; Out.Real(r, 0); Out.String(" (expected 1.0E+37)"); Out.Ln;
  d := 1.0D300; Out.LongReal(d, 0); Out.String(" (expected 1.0D+300)"); Out.Ln;
  bits := 3FEFFFFFFFFFFFFFH; SYSTEM.GET(SYSTEM.ADR(bits), d);  (* the double below 1.0 *)
  Out.LongReal(d, 0); Out.String(" (expected 1.0D+000: 0.99999999999999989 rounded)"); Out.Ln
END OutExponent.
