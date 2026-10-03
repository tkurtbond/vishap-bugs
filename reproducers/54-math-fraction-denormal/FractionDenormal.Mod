MODULE FractionDenormal; (* fraction, ulp and scale of denormal numbers *)
IMPORT SYSTEM, Math, MathL, Out;
VAR x: REAL; i: SYSTEM.INT32; a: LONGREAL; h: SYSTEM.INT64;
PROCEDURE R(t: ARRAY OF CHAR; v: REAL; e: ARRAY OF CHAR);
BEGIN i := SYSTEM.VAL(SYSTEM.INT32, v); Out.String(t); Out.Hex(i, 8);
  Out.String(" (expected "); Out.String(e); Out.Char(")"); Out.Ln
END R;
PROCEDURE L(t: ARRAY OF CHAR; v: LONGREAL; e: ARRAY OF CHAR);
BEGIN h := SYSTEM.VAL(SYSTEM.INT64, v); Out.String(t); Out.Hex(h, 16);
  Out.String(" (expected "); Out.String(e); Out.Char(")"); Out.Ln
END L;
BEGIN
  i := 3; x := SYSTEM.VAL(REAL, i);                  (* 3 * 2^-149 *)
  R("Math.fraction(3*2^-149)    ", Math.fraction(x), "3FC00000, 1.5");
  R("Math.ulp(3*2^-149)         ", Math.ulp(x), "00000001, 2^-149");
  R("Math.scale(1.0, -140)      ", Math.scale(1.0, -140), "00000200, 2^-140");
  R("Math.scale(3*2^-149, 10)   ", Math.scale(x, 10), "00000C00, 3*2^-139");
  h := 3; a := SYSTEM.VAL(LONGREAL, h);              (* 3 * 2^-1074 *)
  L("MathL.fraction(3*2^-1074)  ", MathL.fraction(a), "3FF8000000000000, 1.5");
  L("MathL.ulp(3*2^-1074)       ", MathL.ulp(a), "0000000000000001, 2^-1074");
  L("MathL.scale(1.0, -1060)    ", MathL.scale(1.0D0, -1060), "0000000000004000, 2^-1060")
END FractionDenormal.
