MODULE SqrtRound; (* Math.sqrt and MathL.sqrt are not correctly rounded *)
IMPORT SYSTEM, Math, MathL, Out;
VAR x: REAL; y: LONGREAL; i: SYSTEM.INT32; h: SYSTEM.INT64;
BEGIN
  y := MathL.sqrt(2.0D0); h := SYSTEM.VAL(SYSTEM.INT64, y);
  Out.String("MathL.sqrt(2.0) = "); Out.Hex(h, 16); Out.String(" (expected 3FF6A09E667F3BCD)"); Out.Ln;
  x := Math.sqrt(1.0); i := SYSTEM.VAL(SYSTEM.INT32, x);
  Out.String("Math.sqrt(1.0)  = "); Out.Hex(i, 8); Out.String(" (expected 3F800000)"); Out.Ln
END SqrtRound.
