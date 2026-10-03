MODULE ExponentDenormal; (* Math.exponent of a denormal is expoMin - 1 *)
IMPORT SYSTEM, Math, MathL, Out;
VAR i: SYSTEM.INT32; h: HUGEINT; x: REAL; y: LONGREAL;
BEGIN
  i := 1; x := SYSTEM.VAL(REAL, i);          (* 2^-149, the smallest REAL denormal *)
  Out.String("Math.exponent(2^-149)   = "); Out.Int(Math.exponent(x), 0); Out.String(" (expected -149)"); Out.Ln;
  i := 400000H; x := SYSTEM.VAL(REAL, i);    (* 2^-127 *)
  Out.String("Math.exponent(2^-127)   = "); Out.Int(Math.exponent(x), 0); Out.String(" (expected -127)"); Out.Ln;
  i := 200000H; x := SYSTEM.VAL(REAL, i);    (* 2^-128 *)
  Out.String("Math.exponent(2^-128)   = "); Out.Int(Math.exponent(x), 0); Out.String(" (expected -128)"); Out.Ln;
  h := 1; y := SYSTEM.VAL(LONGREAL, h);      (* 2^-1074 *)
  Out.String("MathL.exponent(2^-1074) = "); Out.Int(MathL.exponent(y), 0); Out.String(" (expected -1074)"); Out.Ln
END ExponentDenormal.
