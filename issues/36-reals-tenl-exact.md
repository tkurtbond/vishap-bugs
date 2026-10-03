# Reals.TenL is not correctly rounded

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Reals.TenL(e)` is not the double nearest 10^e for 252 of the exponents
0..308 (`TenL(33)` is 46C8A6E32246C99D, not ...9C; `TenL(300)` is four units
in the last place high), and a negative `e` gives 10.

## Reproducer

`TenL.Mod`:

```oberon
MODULE TenL; (* Reals.TenL(e) is not the double nearest 10^e *)
IMPORT SYSTEM, Reals, Out;
PROCEDURE Show(e: INTEGER; expected: ARRAY OF CHAR);
  VAR bits: HUGEINT; x: LONGREAL;
BEGIN
  x := Reals.TenL(e); bits := SYSTEM.VAL(HUGEINT, x);
  Out.String("TenL("); Out.Int(e, 0); Out.String("): ");
  Out.Hex(bits, 16); Out.String(" (expected "); Out.String(expected); Out.String(")"); Out.Ln
END Show;
BEGIN
  Show(33, "46C8A6E32246C99C"); Show(100, "54B249AD2594C37D"); Show(300, "7E37E43C8800759C")
END TenL.
```

With voc at `master`:

```
$ voc -O2 TenL.Mod -m
TenL.Mod  Compiling TenL.  Main program.  1004 chars.
$ ./TenL
TenL(33): 46C8A6E32246C99D (expected 46C8A6E32246C99C)
TenL(100): 54B249AD2594C37E (expected 54B249AD2594C37D)
TenL(300): 7E37E43C880075A0 (expected 7E37E43C8800759C)
(exit status 0)
```

## Cause and fix

TenL computed 10^e by squaring 10 and multiplying the powers it needed,
each product rounded, so 252 of the exponents 0..308 gave a double other
than the one nearest 10^e: TenL(33) was 46C8A6E32246C99D, not
46C8A6E32246C99C; TenL(300) was four units in the last place high.
A negative e gave 10. TenL now builds the numeral 1E<e> and reads it
with C's strtod, which rounds correctly, for any e.

Texts.Scan uses TenL to scale the numbers it reads, so its LONGREALs
come out nearer too. (Reals.Ten, which computes in LONGREAL and
rounds once, is correct for 0..38.)

With the fix:

```
$ ./TenL
TenL(33): 46C8A6E32246C99C (expected 46C8A6E32246C99C)
TenL(100): 54B249AD2594C37D (expected 54B249AD2594C37D)
TenL(300): 7E37E43C8800759C (expected 7E37E43C8800759C)
(exit status 0)
```

The fix is `patches/0036-Reals.TenL-correctly-rounded.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
