MODULE TrigBits; (* reads bit patterns (hex) of doubles; writes MathL sin, cos, tan of each, and Math's of the REAL nearest *)
IMPORT SYSTEM, In, Out, Math, MathL;
VAR h: SYSTEM.INT64; i: SYSTEM.INT32; d: LONGREAL; x: REAL;
PROCEDURE L(y: LONGREAL); VAR h: SYSTEM.INT64; BEGIN h := SYSTEM.VAL(SYSTEM.INT64, y); Out.Hex(h, 16); Out.Char(" ") END L;
PROCEDURE R(y: REAL); VAR i: SYSTEM.INT32; BEGIN i := SYSTEM.VAL(SYSTEM.INT32, y); Out.Hex(i, 8); Out.Char(" ") END R;
BEGIN
  In.Open; In.HugeInt(h);
  WHILE In.Done DO
    d := SYSTEM.VAL(LONGREAL, h); x := SHORT(d);
    L(MathL.sin(d)); L(MathL.cos(d)); L(MathL.tan(d)); R(Math.sin(x)); R(Math.cos(x)); R(Math.tan(x)); Out.Ln;
    In.HugeInt(h)
  END
END TrigBits.
