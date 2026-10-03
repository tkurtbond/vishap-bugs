MODULE StringsCap; (* Strings.Cap of an array that is full, with no 0X *)
IMPORT Strings, Out;
VAR s: ARRAY 4 OF CHAR;
BEGIN
  s[0] := "a"; s[1] := "b"; s[2] := "c"; s[3] := "d";
  Strings.Cap(s);
  Out.Char(s[0]); Out.Char(s[1]); Out.Char(s[2]); Out.Char(s[3]);
  Out.String(" (expected ABCD)"); Out.Ln
END StringsCap.
