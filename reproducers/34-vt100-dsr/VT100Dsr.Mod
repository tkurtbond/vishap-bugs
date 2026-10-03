MODULE VT100Dsr; (* DSR(n) sends 6 whatever n is *)
IMPORT VT100, Out;
BEGIN
  VT100.DSR(5); Out.String(" (expected ESC[5n)"); Out.Ln
END VT100Dsr.
