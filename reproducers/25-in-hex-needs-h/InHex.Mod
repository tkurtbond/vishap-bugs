MODULE InHex; (* In.LongInt reads hexadecimal digits without an H *)
IMPORT In, Out;
VAR i: LONGINT;
BEGIN
  In.LongInt(i); IF In.Done THEN Out.Int(i, 0); Out.String(" read from 12AB (expected In.Done FALSE)") ELSE Out.String("In.Done FALSE") END; Out.Ln;
  In.Open;
  In.LongInt(i); Out.Int(i, 0); Out.String(" (expected 255, from 0FFH)"); Out.Ln
END InHex.
