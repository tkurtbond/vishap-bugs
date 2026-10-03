MODULE StringsPos; (* Strings.Pos with a negative start *)
IMPORT Strings, Out;
BEGIN
  Out.Int(Strings.Pos("c", "abc", -2), 0); Out.String(" (expected 2)"); Out.Ln
END StringsPos.
