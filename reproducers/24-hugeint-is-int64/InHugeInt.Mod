MODULE InHugeInt; (* In.HugeInt: a HUGEINT variable is not accepted *)
IMPORT In, Out;
VAR h: HUGEINT;
BEGIN
  In.HugeInt(h); Out.Int(h, 0); Out.Ln
END InHugeInt.
