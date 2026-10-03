MODULE Cap; (* CAP of a character that is not a lower-case letter changes it *)
IMPORT Out;
CONST seven = CAP("7");                    (* folded *)
VAR c: CHAR;
BEGIN
  Out.Int(ORD(seven), 0); Out.String(" (expected 55, ORD of 7)"); Out.Ln;
  c := "{"; c := CAP(c);                   (* at run time *)
  Out.Char(c); Out.String(" (expected {)"); Out.Ln;
  c := "A"; c := CAP(c); Out.Char(c); Out.String(" (expected A)"); Out.Ln;
  c := "z"; c := CAP(c); Out.Char(c); Out.String(" (expected Z)"); Out.Ln
END Cap.
