MODULE SmallLiteral; (* a literal below about 1D-307 (or 1E-37) is "number too large" *)
IMPORT SYSTEM, Out;
CONST minNormal = 2.2250738585072014D-308; minNormalReal = 1.17549435E-38;
VAR h: HUGEINT; x: LONGREAL; i: SYSTEM.INT32; r: REAL;
BEGIN
  x := minNormal; h := SYSTEM.VAL(HUGEINT, x);
  Out.Hex(h, 16); Out.String(" (expected 0010000000000000)"); Out.Ln;
  r := minNormalReal; i := SYSTEM.VAL(SYSTEM.INT32, r);
  Out.Hex(i, 8); Out.String(" (expected 00800000)"); Out.Ln
END SmallLiteral.
