MODULE StrToReal; (* Strings.StrToLongReal and StrToReal do not round correctly *)
IMPORT Strings, Out;
VAR d, ten: LONGREAL; r, tenR: REAL;
BEGIN (* the comparison values are made by one correctly rounded operation on exact values *)
  ten := 10.0D0; tenR := 10.0E0;
  Strings.StrToLongReal("0.3", d);
  IF d = 3.0D0 / ten THEN Out.String("ok") ELSE Out.String("StrToLongReal(0.3) is not the double nearest 0.3") END; Out.Ln;
  Strings.StrToLongReal("1.0E23", d);
  IF d = 1.0D22 * ten THEN Out.String("ok") ELSE Out.String("StrToLongReal(1.0E23) is not the double nearest 10^23") END; Out.Ln;
  Strings.StrToReal("0.7", r);
  IF r = 7.0E0 / tenR THEN Out.String("ok") ELSE Out.String("StrToReal(0.7) is not the REAL nearest 0.7") END; Out.Ln
END StrToReal.
