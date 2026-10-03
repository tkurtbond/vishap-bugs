MODULE DivModMin; (* DIV and MOD of a large negative dividend overflow in SYSTEM_DIV/SYSTEM_MOD *)
IMPORT Out;
VAR x, y: LONGINT;
BEGIN (* compile with -OC: LONGINT is 64 bits *)
  x := MIN(LONGINT); y := 2;
  Out.Int(x DIV y, 0); Out.String(" (expected -4611686018427387904)"); Out.Ln;
  Out.Int(x MOD y, 0); Out.String(" (expected 0)"); Out.Ln;
  x := MIN(LONGINT) + 1;
  Out.Int(x DIV y, 0); Out.String(" (expected -4611686018427387904)"); Out.Ln;
  Out.Int(x MOD y, 0); Out.String(" (expected 1)"); Out.Ln;
  x := MAX(LONGINT); y := -2;
  Out.Int(x DIV y, 0); Out.String(" (expected -4611686018427387904)"); Out.Ln;
  Out.Int(x MOD y, 0); Out.String(" (expected -1)"); Out.Ln;
  x := MIN(LONGINT); y := -3;
  Out.Int(x DIV y, 0); Out.String(" (expected 3074457345618258602)"); Out.Ln;
  Out.Int(x MOD y, 0); Out.String(" (expected -2)"); Out.Ln
END DivModMin.
