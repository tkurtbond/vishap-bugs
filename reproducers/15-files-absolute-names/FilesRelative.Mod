MODULE FilesRelative; (* Files keeps a name relative to the directory current at New/Old *)
(* Run in a directory with a subdirectory "sub": mkdir -p sub *)
IMPORT Files, Platform, Out;
VAR f, g: Files.File; r: Files.Rider; res: INTEGER; dir: ARRAY 4 OF CHAR;
BEGIN
  f := Files.New("sub/a.txt"); Files.Set(r, f, 0); Files.Write(r, "1"); Files.Register(f);
  dir := "sub"; res := Platform.Chdir(dir);
  (* "a.txt" here is the file f still refers to; registering it renames
     the old version by f's name, "sub/a.txt", now relative to "sub" *)
  g := Files.New("a.txt"); Files.Set(r, g, 0); Files.Write(r, "2"); Files.Register(g);
  Out.String("ok"); Out.Ln
END FilesRelative.
