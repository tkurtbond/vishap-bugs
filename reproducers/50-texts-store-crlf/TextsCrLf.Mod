MODULE TextsCrLf; (* Store writes CR LF of a plain text file as two line ends *)
IMPORT Files, Texts, Out;
VAR f: Files.File; r: Files.Rider; T: Texts.Text; R: Texts.Reader; ch: CHAR; n: INTEGER;
PROCEDURE Lines(T: Texts.Text): INTEGER;
  VAR n: INTEGER;
BEGIN n := 0; Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO IF ch = 0DX THEN INC(n) END; Texts.Read(R, ch) END;
  RETURN n
END Lines;
BEGIN
  f := Files.New("crlf.txt"); Files.Set(r, f, 0);
  Files.Write(r, "a"); Files.Write(r, 0DX); Files.Write(r, 0AX);
  Files.Write(r, "b"); Files.Write(r, 0DX); Files.Write(r, 0AX); Files.Register(f);
  NEW(T); Texts.Open(T, "crlf.txt");        (* a plain text: CR LF read as it is *)
  Texts.Close(T, "crlf.text");              (* stored as an Oberon text *)
  NEW(T); Texts.Open(T, "crlf.text");
  n := Lines(T); Out.Int(n, 0); Out.String(" line ends (expected 2)"); Out.Ln
END TextsCrLf.
