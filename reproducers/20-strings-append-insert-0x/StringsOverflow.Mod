MODULE StringsOverflow; (* Strings.Append and Insert: a result too long for dest *)
IMPORT Strings, Out;
VAR s: ARRAY 6 OF CHAR; i: INTEGER;
PROCEDURE Show(s: ARRAY OF CHAR);
  VAR i: INTEGER;
BEGIN i := 0;
  WHILE (i < LEN(s)) & (s[i] # 0X) DO Out.Char(s[i]); INC(i) END;
  IF i = LEN(s) THEN Out.String(" (no 0X)") END; Out.Ln
END Show;
BEGIN
  s := "abc"; Strings.Append("XYZ", s); Show(s);   (* expected abcXY, ended by 0X *)
  s := "abc"; Strings.Insert("XYZ", 1, s); Show(s)  (* expected aXYZb, ended by 0X *)
END StringsOverflow.
