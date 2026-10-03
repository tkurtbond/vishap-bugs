MODULE StringsReplace; (* Strings.Replace deletes pos + Length(source) characters *)
IMPORT Strings, Out;
VAR s: ARRAY 32 OF CHAR;
BEGIN
  s := "abcdefgh"; Strings.Replace("XY", 3, s);
  Out.String(s); Out.String(" (expected abcXYfgh)"); Out.Ln
END StringsReplace.
