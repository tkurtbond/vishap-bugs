MODULE MathLSmall; (* MathL.small is not the smallest normal LONGREAL, 2^-1022 *)
IMPORT SYSTEM, MathL, Out;
VAR h: HUGEINT; x: LONGREAL;
BEGIN
  x := MathL.small; h := SYSTEM.VAL(HUGEINT, x);
  Out.String("MathL.small = "); Out.Hex(h, 16); Out.String(" (expected 0010000000000000)"); Out.Ln
END MathLSmall.
