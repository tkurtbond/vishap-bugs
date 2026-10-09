# A fixed-array value parameter accepts an array of another type and reads past its end

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

A value parameter of type `ARRAY 8 OF CHAR` accepts a shorter array
(`ARRAY 4 OF CHAR`) or an open array, where Oberon-2 allows only its own
type. The callee copies 8 bytes from whatever it is given: from a shorter
actual it reads past the end, so the parameter holds the bytes that follow
(here the next field of a record), and an open actual of any length is cut
to 8 characters, with no 0X and without the length test that the
assignment `n := s` makes: `Assign(long)`, last, stops with that test's
`Halt(-2)`.

## Reproducer

`ArrayParShort.Mod`:

```oberon
MODULE ArrayParShort; (* a shorter array passed to a fixed-array value parameter *)
IMPORT Out;
TYPE Name = ARRAY 8 OF CHAR;
VAR r: RECORD a, b: ARRAY 4 OF CHAR END;

PROCEDURE Show(n: Name);
  VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(n) - 1 DO
    IF n[i] = 0X THEN Out.String(" 0X") ELSE Out.Char(" "); Out.Char(n[i]) END
  END;
  Out.Ln
END Show;

BEGIN
  r.a := "abc"; r.b := "XYZ";
  Show(r.a); Out.String("(expected err 113: r.a is not a Name)"); Out.Ln
END ArrayParShort.
```

`ArrayParOpen.Mod`:

```oberon
MODULE ArrayParOpen; (* an open array passed to a fixed-array value parameter *)
IMPORT Out;
TYPE Name = ARRAY 8 OF CHAR;
VAR r: RECORD a, b: ARRAY 4 OF CHAR END; long: ARRAY 32 OF CHAR;

PROCEDURE Show(n: Name);
  VAR i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(n) - 1 DO
    IF n[i] = 0X THEN Out.String(" 0X") ELSE Out.Char(" "); Out.Char(n[i]) END
  END;
  Out.Ln
END Show;

PROCEDURE Pass(VAR s: ARRAY OF CHAR);
BEGIN
  Show(s)
END Pass;

PROCEDURE Assign(VAR s: ARRAY OF CHAR);
  VAR n: Name;
BEGIN
  n := s
END Assign;

BEGIN
  r.a := "abc"; r.b := "XYZ"; long := "a string of 26 characters";
  Pass(r.a); Pass(long); Out.String("(expected err 113: s is not a Name)"); Out.Ln;
  Assign(long)
END ArrayParOpen.
```

With voc at `master`:

```
$ voc -O2 ArrayParShort.Mod -m
ArrayParShort.Mod  Compiling ArrayParShort.  Main program.  1169 chars.
$ ./ArrayParShort
 a b c 0X X Y Z 0X
(expected err 113: r.a is not a Name)
(exit status 0)
```

```
$ voc -O2 ArrayParOpen.Mod -m
ArrayParOpen.Mod  Compiling ArrayParOpen.  Main program.  1676 chars.
$ ./ArrayParOpen
 a b c 0X X Y Z 0X
 a   s t r i n g
(expected err 113: s is not a Name)
Terminated by Halt(-2). Index out of range.
(exit status 254)
```

## Cause and fix

Oberon2.pdf requires a value parameter's actual to be assignment
compatible with it (10.1), and for an array that means the same type, or
a string constant for an ARRAY n OF CHAR (Appendix A). Param checked it
with CheckAssign, which for array assignment also accepts a shorter
array of the same element type and an open array (its comments cite
Oberon-07): an assignment copies the source's length, and tests an open
array's at run time. A value parameter is copied in the callee instead
(__DUPARR), which knows only the formal's size, so a shorter actual is
read past its end and the parameter holds whatever follows it, and an
open actual is cut to the formal's length with no 0X and no test. Such
an actual is now err 113, incompatible assignment, as Oberon-2 makes it.
Assignment is unchanged.

With the fix:

```
$ voc -O2 ArrayParShort.Mod -m
ArrayParShort.Mod  Compiling ArrayParShort.
  17:   Show(r.a); Out.String("(expected err 113: r.a is not a Name)"); Out.Ln
               ^
    pos   397  err 113  incompatible assignment
Module compilation failed.
(voc's exit status 1)
```

```
$ voc -O2 ArrayParOpen.Mod -m
ArrayParOpen.Mod  Compiling ArrayParOpen.
  17:   Show(s)
             ^
    pos   424  err 113  incompatible assignment
Module compilation failed.
(voc's exit status 1)
```

The fix is `patches/0068-A-fixed-array-value-parameter-takes-only-an-actual-o.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
