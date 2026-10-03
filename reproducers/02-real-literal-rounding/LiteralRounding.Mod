MODULE LiteralRounding; (* the scanner does not round decimal real literals correctly *)
IMPORT Out;
CONST (* compared by the compiler, with the values its scanner made *)
  a = 1.1D3 = 1100;                        (* 1.1D3 is 1100.0000000000002 *)
  b = 123.456D0 * 1000 = 123456;           (* 123.456D0 is 123.45600000000002 *)
  c = 1.0D23 = 1.0D22 * 10;                (* 1.0D23 is 1.0000000000000001D23 *)
BEGIN
  IF a THEN Out.String("ok") ELSE Out.String("1.1D3 # 1100") END; Out.Ln;
  IF b THEN Out.String("ok") ELSE Out.String("123.456D0 * 1000 # 123456") END; Out.Ln;
  IF c THEN Out.String("ok") ELSE Out.String("1.0D23 # 1.0D22 * 10") END; Out.Ln
END LiteralRounding.
