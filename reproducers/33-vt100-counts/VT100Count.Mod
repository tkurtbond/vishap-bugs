MODULE VT100Count; (* a count of 10 or more is cut to its first digit *)
IMPORT VT100, Out;
BEGIN
  VT100.CUU(12); Out.String(" (expected ESC[12A)"); Out.Ln;
  VT100.CUP(12345, 67); Out.String(" (expected ESC[12345;67H)"); Out.Ln
END VT100Count.
