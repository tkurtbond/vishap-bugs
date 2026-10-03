MODULE Abs64; (* ABS of a 64-bit value with side effects is cut to 32 bits *)
IMPORT Out;
VAR a: ARRAY 2 OF LONGINT; i: LONGINT;
PROCEDURE Next(): LONGINT; BEGIN INC(i); RETURN i END Next;
BEGIN (* compile with -OC: LONGINT is 64 bits *)
  a[1] := -5000000000; i := 0;
  Out.Int(ABS(a[Next()]), 0); Out.String(" (expected 5000000000)"); Out.Ln
END Abs64.
