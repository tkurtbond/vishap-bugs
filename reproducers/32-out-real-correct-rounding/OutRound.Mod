MODULE OutRound; (* Out.LongReal does not write correctly rounded digits *)
IMPORT Out;
PROCEDURE Show(i: INTEGER; expected: ARRAY OF CHAR);
  VAR d: LONGREAL;
BEGIN
  d := i; d := d / 7.0D0;
  Out.Int(i, 2); Out.String("/7 = "); Out.LongReal(d, 24);
  Out.String(" (expected "); Out.String(expected); Out.String(")"); Out.Ln
END Show;
BEGIN
  Show(1, "1.4285714285714285D-001");
  Show(4, "5.7142857142857140D-001");
  Show(27, "3.8571428571428572D+000")  (* what voc writes reads back as another double *)
END OutRound.
