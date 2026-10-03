MODULE FilesReadString; (* Files.ReadString into an array too small for the string *)
IMPORT Files, Out;
VAR f: Files.File; r: Files.Rider; s: ARRAY 4 OF CHAR;
BEGIN
  f := Files.New("strings.dat"); Files.Set(r, f, 0);
  Files.WriteString(r, "abcdefgh"); Files.WriteString(r, "xy");
  Files.Register(f);
  Files.Set(r, f, 0);
  Files.ReadString(r, s); Out.String(s); Out.String(" (expected abc)"); Out.Ln;
  Files.ReadString(r, s); Out.String(s); Out.String(" (expected xy)"); Out.Ln
END FilesReadString.
