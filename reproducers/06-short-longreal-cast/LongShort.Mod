MODULE LongShort; (* SHORT(x) of a LONGREAL is not rounded to REAL inside an expression *)
IMPORT Out;
VAR x, y, z: LONGREAL; r: REAL;
BEGIN
  x := 0.1D0;
  r := SHORT(x);                    (* rounded to REAL: stored in a REAL *)
  y := LONG(SHORT(x));              (* should be the same value *)
  z := SHORT(x) * 1.0D0;            (* SHORT(x) is a REAL operand: the same value again *)
  IF y = LONG(r) THEN Out.String("ok") ELSE Out.String("LONG(SHORT(x)) is x, not x rounded to REAL") END; Out.Ln;
  IF z = LONG(r) THEN Out.String("ok") ELSE Out.String("SHORT(x) * 1.0D0 is x, not x rounded to REAL") END; Out.Ln
END LongShort.
