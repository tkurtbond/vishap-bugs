MODULE StringsExtract; (* Strings.Extract into a dest too small for the part *)
IMPORT Strings, Out;
VAR d: ARRAY 4 OF CHAR;
BEGIN
  Strings.Extract("abcdefgh", 1, 6, d);
  Out.String(d); Out.String(" (expected bcd)"); Out.Ln
END StringsExtract.
