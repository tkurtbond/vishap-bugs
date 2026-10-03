MODULE ScanBits; (* the bits of each number Texts.Scan reads from ScanBits.vals *)
IMPORT SYSTEM, Texts, Out;
VAR T: Texts.Text; S: Texts.Scanner; i: SYSTEM.INT32; h: SYSTEM.INT64;
BEGIN
  NEW(T); Texts.Open(T, "ScanBits.vals"); Texts.OpenScanner(S, T, 0); Texts.Scan(S);
  WHILE (S.class = Texts.Real) OR (S.class = Texts.LongReal) DO
    IF S.class = Texts.Real THEN i := SYSTEM.VAL(SYSTEM.INT32, S.x); Out.String("R "); Out.Hex(i, 8)
    ELSE h := SYSTEM.VAL(SYSTEM.INT64, S.y); Out.String("L "); Out.Hex(h, 16)
    END;
    Out.Ln; Texts.Scan(S)
  END
END ScanBits.
