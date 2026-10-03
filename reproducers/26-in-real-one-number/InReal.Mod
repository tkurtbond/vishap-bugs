MODULE InReal; (* In.LongReal: a line longer than 15 characters, and two numbers on a line *)
IMPORT In, Out;
VAR x, y: LONGREAL;
BEGIN
  In.LongReal(x); Out.LongReal(x, 0); Out.String(" (expected 3.14159265358979, as Out.LongReal prints it)"); Out.Ln;
  In.LongReal(x); In.LongReal(y);
  Out.LongReal(x, 0); Out.String(" "); Out.LongReal(y, 0); Out.String(" (expected 1.5 2.5)"); Out.Ln;
  In.LongReal(x); IF In.Done THEN Out.String("Done after abc (expected FALSE)") ELSE Out.String("not Done after abc") END; Out.Ln
END InReal.
