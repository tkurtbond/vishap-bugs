MODULE FilesRenameOpen; (* Files.Rename of a file the program has open *)
IMPORT Files, Out;
VAR f, g: Files.File; r: Files.Rider; res: INTEGER;

PROCEDURE Make(name: ARRAY OF CHAR): Files.File;
  VAR f: Files.File;
BEGIN f := Files.New(name); Files.Set(r, f, 0); Files.Write(r, "x"); Files.Register(f); RETURN f
END Make;

BEGIN
  g := Make("b.txt");                          (* g is still open *)
  Files.Rename("b.txt", "c.txt", res);
  Out.String("Rename of an open file: res = "); Out.Int(res, 0); Out.Ln;
  f := Make("c.txt");                          (* replaces the file g has open *)
  Out.String("c.txt made again"); Out.Ln
END FilesRenameOpen.
