MODULE FileDate; (* Files.GetDate under -O2, where LONGINT has 4 bytes *)
IMPORT Files, Platform, Out;
VAR f: Files.File; t, d, ft, fd: LONGINT;
PROCEDURE Date(t, d: LONGINT);
BEGIN
  Out.Int(2000 + d DIV 512, 0); Out.Char("-"); Out.Int(d DIV 32 MOD 16, 2); Out.Char("-"); Out.Int(d MOD 32, 2);
  Out.Char(" "); Out.Int(t DIV 4096, 2); Out.Char(":"); Out.Int(t DIV 64 MOD 64, 2)
END Date;
BEGIN
  f := Files.New("date.txt"); Files.Register(f);
  Platform.GetClock(t, d); f := Files.Old("date.txt"); Files.GetDate(f, ft, fd);
  Out.String("now                "); Date(t, d); Out.Ln;
  Out.String("file's date        "); Date(ft, fd); Out.String(" (expected the same, to the minute)"); Out.Ln
END FileDate.
