MODULE LargeTrig; (* Math and MathL: sin, cos (and Math.tan) of a large argument are 0, with LossOfAccuracy *)
IMPORT Math, MathL, Out;
VAR x: REAL; y: LONGREAL;
BEGIN
  x := 10000.0; Math.ClearError;
  Out.String("Math.sin(10000.0)  = "); Out.Real(Math.sin(x), 14); Out.String(", err "); Out.Int(Math.err, 0);
  Out.String(" (expected -3.05614E-01, err 0)"); Out.Ln;
  x := 1.0E5; x := x * x; x := x * x * x; Math.ClearError;   (* 1.0E30, made at run time *)
  Out.String("Math.tan(1.0E30)   = "); Out.Real(Math.tan(x), 14); Out.String(", err "); Out.Int(Math.err, 0);
  Out.String(" (expected about 1.2936, err 0)"); Out.Ln;
  y := 1.0D5; y := y * y; Math.ClearError;           (* 1.0D10 *)
  Out.String("MathL.sin(1.0D10)  = "); Out.LongReal(MathL.sin(y), 24); Out.String(", err "); Out.Int(Math.err, 0);
  Out.String(" (expected -4.875060251...D-001, err 0)"); Out.Ln;
  y := y * y; y := y * 100.0D0; Math.ClearError;     (* 1.0D22 *)
  Out.String("MathL.cos(1.0D22)  = "); Out.LongReal(MathL.cos(y), 24); Out.String(", err "); Out.Int(Math.err, 0);
  Out.String(" (expected 5.232147853951389D-001, err 0)"); Out.Ln
END LargeTrig.
