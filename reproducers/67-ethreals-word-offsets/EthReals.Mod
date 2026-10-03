MODULE EthReals; (* ethReals reads the wrong half of a LONGREAL, so ethStrings.RealToStr is wrong *)
IMPORT ethReals, ethStrings, Out;
VAR s: ARRAY 32 OF CHAR;
BEGIN
  Out.String("ethReals.ExpoL(12345.678D0) "); Out.Int(ethReals.ExpoL(12345.678D0), 0);
  Out.String(" (expected 1036)"); Out.Ln;
  ethStrings.RealToStr(12345.678D0, s); Out.String(s); Out.String(" (expected 12345.678)"); Out.Ln;
  ethStrings.RealToStr(0.25D0, s); Out.String(s); Out.String(" (expected 0.25)"); Out.Ln;
  ethStrings.RealToStr(3.0D0, s); Out.String(s); Out.String(" (expected 3)"); Out.Ln
END EthReals.
