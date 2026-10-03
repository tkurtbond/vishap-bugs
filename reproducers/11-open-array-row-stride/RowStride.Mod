MODULE RowStride; (* a row of a multi-dimensional open array, passed on as an open array *)
IMPORT Out;
VAR grid: ARRAY 3, 4 OF INTEGER; r, c: INTEGER;

PROCEDURE Sum(VAR row: ARRAY OF INTEGER): LONGINT;
  VAR i, s: LONGINT;
BEGIN s := 0; FOR i := 0 TO LEN(row) - 1 DO s := s + row[i] END; RETURN s
END Sum;

PROCEDURE RowSum(VAR a: ARRAY OF ARRAY OF INTEGER; r: INTEGER): LONGINT;
BEGIN RETURN Sum(a[r])
END RowSum;

BEGIN
  FOR r := 0 TO 2 DO FOR c := 0 TO 3 DO grid[r, c] := 10 * r + c END END;
  Out.Int(Sum(grid[2]), 0); Out.String(" (expected 86)"); Out.Ln;
  Out.Int(RowSum(grid, 2), 0); Out.String(" (expected 86)"); Out.Ln
END RowStride.
