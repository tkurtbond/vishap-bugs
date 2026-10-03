MODULE OutSubnormal; (* Out.LongReal writes a subnormal number as 0 *)
IMPORT SYSTEM, Out;
VAR d: LONGREAL; bits: SYSTEM.INT64;
BEGIN
  bits := 1; SYSTEM.GET(SYSTEM.ADR(bits), d);                 (* the smallest double, 4.9D-324 *)
  Out.LongReal(d, 0); Out.String(" (expected 4.9D-324)"); Out.Ln;
  bits := 8000000000000H; SYSTEM.GET(SYSTEM.ADR(bits), d);    (* 2^-1023, 1.1D-308 *)
  Out.LongReal(d, 0); Out.String(" (expected 1.1D-308)"); Out.Ln
END OutSubnormal.
