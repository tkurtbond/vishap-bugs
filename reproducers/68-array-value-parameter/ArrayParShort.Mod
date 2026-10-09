MODULE ArrayParShort; (* a shorter array passed to a fixed-array value parameter *)
IMPORT Out;
TYPE Name = ARRAY 8 OF CHAR;
VAR r: RECORD a, b: ARRAY 4 OF CHAR END;

PROCEDURE Show(n: Name);
  VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(n) - 1 DO
    IF n[i] = 0X THEN Out.String(" 0X") ELSE Out.Char(" "); Out.Char(n[i]) END
  END;
  Out.Ln
END Show;

BEGIN
  r.a := "abc"; r.b := "XYZ";
  Show(r.a); Out.String("(expected err 113: r.a is not a Name)"); Out.Ln
END ArrayParShort.
