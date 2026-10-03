MODULE NestedLengths; (* a nested procedure and its parent's multi-dimensional open array *)
IMPORT Out;
VAR grid: ARRAY 2, 7 OF INTEGER;

PROCEDURE Outer(VAR x: ARRAY OF ARRAY OF INTEGER): LONGINT;
  PROCEDURE Inner(): LONGINT;
  BEGIN RETURN x[1, 6] + LEN(x, 1)
  END Inner;
BEGIN RETURN Inner()
END Outer;

BEGIN
  grid[1, 6] := 100;
  Out.Int(Outer(grid), 0); Out.String(" (expected 107)"); Out.Ln
END NestedLengths.
