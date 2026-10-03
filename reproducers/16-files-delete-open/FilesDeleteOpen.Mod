MODULE FilesDeleteOpen; (* Files.Delete of a file the program has open *)
IMPORT Files, Out;
VAR f: Files.File; r: Files.Rider; res: INTEGER;

PROCEDURE Make(name: ARRAY OF CHAR): Files.File;
  VAR f: Files.File;
BEGIN f := Files.New(name); Files.Set(r, f, 0); Files.Write(r, "x"); Files.Register(f); RETURN f
END Make;

BEGIN
  f := Make("a.txt");                          (* f is still open *)
  Files.Delete("a.txt", res);
  Out.String("Delete of an open file: res = "); Out.Int(res, 0); Out.String(" (expected 0)"); Out.Ln;
  IF Files.Old("a.txt") = NIL THEN Out.String("a.txt is gone") ELSE Out.String("a.txt is still there") END; Out.Ln
END FilesDeleteOpen.
