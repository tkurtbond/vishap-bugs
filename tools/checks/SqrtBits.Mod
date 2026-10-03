MODULE SqrtBits; (* reads bit patterns (hex), writes MathL.sqrt of each as a bit pattern *)
IMPORT SYSTEM, In, Out, MathL;
VAR h: SYSTEM.INT64; d: LONGREAL;
BEGIN
  In.Open; In.HugeInt(h);
  WHILE In.Done DO
    d := SYSTEM.VAL(LONGREAL, h); d := MathL.sqrt(d); h := SYSTEM.VAL(SYSTEM.INT64, d);
    Out.Hex(h, 16); Out.Ln; In.HugeInt(h)
  END
END SqrtBits.
