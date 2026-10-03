MODULE OutDigits; (* reads bit patterns (hex), writes each with Out.LongReal(x, 24): 17 digits *)
IMPORT SYSTEM, In, Out;
VAR h: LONGINT; d: LONGREAL;  (* -OC: LONGINT has 64 bits *)
BEGIN
  In.Open; In.LongInt(h);
  WHILE In.Done DO SYSTEM.GET(SYSTEM.ADR(h), d); Out.LongReal(d, 24); Out.Ln; In.LongInt(h) END
END OutDigits.
