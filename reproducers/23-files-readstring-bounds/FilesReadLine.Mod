MODULE FilesReadLine; (* Files.ReadLine into an array too small for the line *)
IMPORT Files, Out;
VAR f: Files.File; r: Files.Rider; s: ARRAY 4 OF CHAR;

PROCEDURE WriteLine(text: ARRAY OF CHAR);
  VAR i: INTEGER;
BEGIN i := 0; WHILE text[i] # 0X DO Files.Write(r, text[i]); INC(i) END; Files.Write(r, 0AX)
END WriteLine;

BEGIN
  f := Files.New("lines.txt"); Files.Set(r, f, 0);
  WriteLine("abcdefgh"); WriteLine("xy"); Files.Register(f);
  Files.Set(r, f, 0);
  Files.ReadLine(r, s); Out.String(s); Out.String(" (expected abc)"); Out.Ln;
  Files.ReadLine(r, s); Out.String(s); Out.String(" (expected xy)"); Out.Ln
END FilesReadLine.
