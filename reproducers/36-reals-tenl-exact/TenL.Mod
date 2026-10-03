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
