MODULE MaxReal; (* MAX(LONGREAL) is not the largest LONGREAL, MAX(REAL) not the largest REAL *)
IMPORT SYSTEM, Out;
VAR d: LONGREAL; r: REAL; bits: SYSTEM.INT64; bits32: SYSTEM.INT32;
BEGIN
  d := MAX(LONGREAL); SYSTEM.GET(SYSTEM.ADR(d), bits);
  Out.String("MAX(LONGREAL): "); Out.Hex(bits, 16);
  Out.String(", expected 7FEFFFFFFFFFFFFF"); Out.Ln;
  r := MAX(REAL); SYSTEM.GET(SYSTEM.ADR(r), bits32);
  Out.String("MAX(REAL):     "); Out.Hex(bits32, 8);
  Out.String(", expected 7F7FFFFF"); Out.Ln;
  IF MAX(REAL) = r THEN Out.String("ok") ELSE Out.String("MAX(REAL) folded # MAX(REAL) stored") END; Out.Ln
END MaxReal.
