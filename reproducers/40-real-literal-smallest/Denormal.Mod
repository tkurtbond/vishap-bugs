MODULE Denormal; (* the smallest denormals as literals *)
IMPORT SYSTEM, Out;
VAR h: HUGEINT; x: LONGREAL; i: SYSTEM.INT32; r: REAL;
BEGIN
  x := 4.9406564584124654D-324; h := SYSTEM.VAL(HUGEINT, x); Out.Hex(h, 16); Out.String(" (expected 0000000000000001)"); Out.Ln;
  r := 1.4E-45; i := SYSTEM.VAL(SYSTEM.INT32, r); Out.Hex(i, 8); Out.String(" (expected 00000001)"); Out.Ln;
  x := 0.0D-400; h := SYSTEM.VAL(HUGEINT, x); Out.Hex(h, 16); Out.String(" (expected 0000000000000000)"); Out.Ln
END Denormal.
