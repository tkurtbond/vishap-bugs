MODULE SqrtBitsR; (* reads REAL bit patterns (hex), writes Math.sqrt of each as a bit pattern *)
IMPORT SYSTEM, In, Out, Math;
VAR h: LONGINT; i: SYSTEM.INT32; x: REAL;
BEGIN
  In.Open; In.LongInt(h);
  WHILE In.Done DO
    i := SHORT(h); x := SYSTEM.VAL(REAL, i); x := Math.sqrt(x); i := SYSTEM.VAL(SYSTEM.INT32, x);
    Out.Hex(i, 8); Out.Ln; In.LongInt(h)
  END
END SqrtBitsR.
