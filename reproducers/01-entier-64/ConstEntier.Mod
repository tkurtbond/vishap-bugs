MODULE ConstEntier; (* a constant ENTIER >= 2^31 stops the compiler under -OC *)
IMPORT Out;
CONST big = ENTIER(3000000000.5D0);
BEGIN
  Out.Int(big, 0); Out.Ln  (* expected 3000000000 *)
END ConstEntier.
