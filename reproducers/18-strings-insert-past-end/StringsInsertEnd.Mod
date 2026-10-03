MODULE StringsInsertEnd; (* Strings.Insert at a position past the end does nothing *)
IMPORT Strings, Out;
VAR s: ARRAY 32 OF CHAR;
BEGIN
  s := "abc"; Strings.Insert("XYZ", 10, s);
  Out.String(s); Out.String(" (expected abcXYZ)"); Out.Ln
END StringsInsertEnd.
