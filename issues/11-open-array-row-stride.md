# A row of a multi-dimensional open array passed as an open array ignores the row stride

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Inside a procedure with `a: ARRAY OF ARRAY OF INTEGER`, passing `a[r]` to an
`ARRAY OF INTEGER` parameter passes `&a[r]` rather than `&a[r * LEN(a, 1)]`,
so the callee sees elements r .. r + LEN(a, 1) - 1 of the flat data instead
of row r. The same call on a fixed array is right.

## Reproducer

`RowStride.Mod`:

```oberon
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
```

With voc at `master`:

```
$ voc -O2 RowStride.Mod -m
RowStride.Mod  Compiling RowStride.  Main program.  1367 chars.
$ ./RowStride
86 (expected 86)
26 (expected 86)
(exit status 0)
```

## Cause and fix

For a[r] where a is an ARRAY OF ARRAY OF T and a[r] is passed on as an
open array, OPV.design finished the Horner schema with one factor per
dimension not indexed, counting them as (a's type's size - 4) DIV 4. For
an open array parameter that count was too small, so no factor was
written: &a[r] instead of &a[r * LEN(a, 1)], and the callee got elements
r .. r + LEN(a, 1) - 1 of the flat data instead of row r. The dimensions
are now counted from the type of a[r] itself.

With the fix:

```
$ ./RowStride
86 (expected 86)
86 (expected 86)
(exit status 0)
```

The fix is `patches/0011-Index-a-row-of-a-multi-dimensional-open-array-with-t.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
