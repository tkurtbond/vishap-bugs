MODULE RealConstants; (* real constants lose digits in the generated C *)
IMPORT Out;
VAR d, e: LONGREAL; r, s: REAL;
BEGIN
  d := 1.0D0 / 3.0D0;                  (* folded by voc, written to the C file *)
  e := 1.0D0; e := e / 3.0D0;          (* computed at run time *)
  IF d = e THEN Out.String("ok") ELSE Out.String("folded 1.0D0 / 3.0D0 # 1.0D0 / 3.0D0 at run time") END; Out.Ln;
  r := 1.0E0 / 3.0E0;
  s := 1.0E0; s := s / 3.0E0;
  IF r = s THEN Out.String("ok") ELSE Out.String("folded 1.0E0 / 3.0E0 # 1.0E0 / 3.0E0 at run time") END; Out.Ln
END RealConstants.
