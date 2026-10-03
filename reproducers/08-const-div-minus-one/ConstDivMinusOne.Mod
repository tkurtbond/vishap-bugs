MODULE ConstDivMinusOne; (* folding MIN(HUGEINT) DIV (-1) kills the compiler with SIGFPE *)
IMPORT Out;
CONST q = MIN(HUGEINT) DIV (-1);           (* does not fit: should be an error *)
BEGIN
  Out.Int(q, 0); Out.Ln
END ConstDivMinusOne.
