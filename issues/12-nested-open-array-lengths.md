# A nested procedure gets garbage inner lengths for its parent's multi-dimensional open array

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

When a nested procedure uses an enclosing procedure's parameter `x: ARRAY OF
ARRAY OF T`, the generated C copies the outer length twice and never the
inner one, so in the nested procedure `LEN(x, 1)` and every `x[i, j]` use an
uninitialized length: a NIL access trap or a wrong element.

## Reproducer

`NestedLengths.Mod`:

```oberon
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
```

With voc at `master`:

```
$ voc -O2 NestedLengths.Mod -m
NestedLengths.Mod  Compiling NestedLengths.  Main program.  1186 chars.
$ ./NestedLengths
Terminated by Halt(-10). NIL access.
(exit status 246)
```

## Cause and fix

OPC.EnterProc copies an open array parameter used by a nested procedure
into the frame record, with its lengths, but never advanced the
dimension: for x: ARRAY OF ARRAY OF T it wrote _s.x__len = x__len twice
and left _s.x__len1 unset, so in the nested procedure LEN(x, 1) and
every x[i, j] used garbage (a NIL access trap, or a wrong element).

With the fix:

```
$ ./NestedLengths
107 (expected 107)
(exit status 0)
```

The fix is `patches/0012-Copy-every-length-of-an-open-array-parameter-into-a-.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
