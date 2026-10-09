MODULE ArrayParOpen; (* an open array passed to a fixed-array value parameter *)
IMPORT Out;
TYPE Name = ARRAY 8 OF CHAR;
VAR r: RECORD a, b: ARRAY 4 OF CHAR END; long: ARRAY 32 OF CHAR;

PROCEDURE Show(n: Name);
  VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(n) - 1 DO
    IF n[i] = 0X THEN Out.String(" 0X") ELSE Out.Char(" "); Out.Char(n[i]) END
  END;
  Out.Ln
END Show;

PROCEDURE Pass(VAR s: ARRAY OF CHAR);
BEGIN
  Show(s)
END Pass;

PROCEDURE Assign(VAR s: ARRAY OF CHAR);
  VAR n: Name;
BEGIN
  n := s
END Assign;

BEGIN
  r.a := "abc"; r.b := "XYZ"; long := "a string of 26 characters";
  Pass(r.a); Pass(long); Out.String("(expected err 113: s is not a Name)"); Out.Ln;
  Assign(long)
END ArrayParOpen.
