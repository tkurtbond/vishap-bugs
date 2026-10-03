MODULE SuccPred; (* Math.succ/pred: not the neighbouring numbers *)
IMPORT SYSTEM, Math, MathL, Out;
PROCEDURE R(t: ARRAY OF CHAR; x: REAL; expected: ARRAY OF CHAR);
  VAR i: SYSTEM.INT32;
BEGIN i := SYSTEM.VAL(SYSTEM.INT32, x);
  Out.String(t); Out.Hex(i, 8); Out.String(" (expected "); Out.String(expected); Out.String(")"); Out.Ln
END R;
PROCEDURE L(t: ARRAY OF CHAR; x: LONGREAL; expected: ARRAY OF CHAR);
  VAR h: HUGEINT;
BEGIN h := SYSTEM.VAL(HUGEINT, x);
  Out.String(t); Out.Hex(h, 16); Out.String(" (expected "); Out.String(expected); Out.String(")"); Out.Ln
END L;
BEGIN
  R("Math.succ(-1.0)  = ", Math.succ(-1.0), "BF7FFFFF, -0.99999994");
  R("Math.pred(-1.0)  = ", Math.pred(-1.0), "BF800001, -1.0000001");
  R("Math.pred(1.0)   = ", Math.pred(1.0), "3F7FFFFF, 0.99999994");
  R("Math.succ(0.0)   = ", Math.succ(0.0), "00000001");
  L("MathL.succ(-1.0) = ", MathL.succ(-1.0D0), "BFEFFFFFFFFFFFFF");
  L("MathL.pred(1.0)  = ", MathL.pred(1.0D0), "3FEFFFFFFFFFFFFF")
END SuccPred.
