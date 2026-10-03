MODULE ConstProduct; (* a constant product equal to MIN(HUGEINT) is rejected as an overflow *)
IMPORT Out;
CONST p = (-4611686018427387904) * 2;      (* -2^63 = MIN(HUGEINT), fits *)
BEGIN
  Out.Int(p, 0); Out.Ln
END ConstProduct.
