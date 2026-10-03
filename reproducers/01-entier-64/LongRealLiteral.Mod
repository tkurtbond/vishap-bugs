MODULE LongRealLiteral; (* integral LONGREAL literals >= 2^31 are rejected *)
IMPORT Out;
VAR x: LONGREAL;
BEGIN
  x := 2147483647.0D0; Out.LongReal(x, 0); Out.Ln;  (* compiles *)
  x := 2147483648.0D0; Out.LongReal(x, 0); Out.Ln;  (* err: Value out of range *)
  x := 1.0D10;         Out.LongReal(x, 0); Out.Ln;  (* err: Value out of range *)
  x := 1.5D10;         Out.LongReal(x, 0); Out.Ln   (* err: Value out of range *)
END LongRealLiteral.
