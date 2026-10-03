MODULE Checks; (* what differences.md says voc does; compile with voc -O2 Checks.Mod -m *)
IMPORT SYSTEM, Out, Strings, Math, MathL, Reals, Texts, Files, Platform, Modules;
VAR s: ARRAY 4 OF CHAR; x: REAL; y: LONGREAL; i32: SYSTEM.INT32; i: INTEGER; k: LONGINT;
  T: Texts.Text; W: Texts.Writer; R: Texts.Reader; B: Texts.Buffer; ch: CHAR;
  a: ARRAY 8 OF CHAR; d: ARRAY 32 OF CHAR; f, g: Files.File; r: Files.Rider;
  name: ARRAY 256 OF CHAR; big: POINTER TO ARRAY 40000 OF CHAR;
BEGIN
  Out.String("D1  Out.Int(MIN(HUGEINT), 0) ["); Out.Int(MIN(HUGEINT), 0);
  Out.String("], width 24 ["); Out.Int(MIN(HUGEINT), 24); Out.Char("]"); Out.Ln;
  s[0] := "a"; s[1] := "b"; s[2] := "c"; s[3] := "d";
  Out.String("D2  Strings.Pos in a full ARRAY 4 with no 0X: 'cd' at ");
  Out.Int(Strings.Pos("cd", s, 0), 0); Out.String(", 'x' at "); Out.Int(Strings.Pos("x", s, 0), 0); Out.Ln;
  Math.ClearError; x := Math.sinh(89.0);
  Out.String("D3  Math.sinh(89.0) "); Out.Real(x, 15); Out.String(" err "); Out.Int(Math.err, 0); Out.Ln;
  x := Math.small; i32 := SYSTEM.VAL(SYSTEM.INT32, x);
  Out.String("D4  Math.small's bits "); Out.Hex(i32, 8); Out.Ln;
  Texts.OpenWriter(W); Texts.WriteDate(W, 0, ASH(26, 9) + ASH(10, 5) + 3);
  NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Out.String("D5  Texts.WriteDate of 2026-10-03:"); Texts.OpenReader(R, T, 0); Texts.Read(R, ch);
  WHILE ~R.eot DO Out.Char(ch); Texts.Read(R, ch) END; Out.Ln;
  IF Platform.getEnv("HOME", s) THEN END;
  Out.String("D6  Platform.getEnv of HOME into an ARRAY 4: "); Out.String(s); Out.Ln;
  Texts.OpenWriter(W); Texts.WriteString(W, "hello"); NEW(T); Texts.Open(T, ""); Texts.Append(T, W.buf);
  Texts.OpenReader(R, T, 1000); NEW(B); Texts.OpenBuf(B); Texts.Save(T, 3, 1000, B);
  Texts.WriteString(W, "X"); Texts.Insert(T, 1000, W.buf); Texts.Delete(T, 6, 1000);
  Out.String("D7  Texts with positions 1000 in a text of 5: saved "); Out.Int(B.len, 0);
  Out.String(", length after the insertion "); Out.Int(T.len, 0); Out.Ln;
  Math.ClearError; y := MathL.tan(MathL.pi / 2);
  Out.String("D9  MathL.tan(pi/2) "); Out.LongReal(y, 24); Out.String(" err "); Out.Int(Math.err, 0); Out.Ln;
  Out.String("D10 Math.round of 2.5, -2.5, 3.5: "); Out.Int(Math.round(2.5), 0); Out.Char(" ");
  Out.Int(Math.round(-2.5), 0); Out.Char(" "); Out.Int(Math.round(3.5), 0); Out.Ln;
  a := "keep"; Modules.GetArg(5, a); Out.String("D11 Modules.GetArg(5, a) with 1 argument leaves a: "); Out.String(a); Out.Ln;
  f := Files.New("two.txt"); Files.Set(r, f, 0); Files.Write(r, "a"); Files.Register(f);
  f := Files.Old("two.txt"); g := Files.Old("two.txt");
  Out.String("D14 two Files.Old of one file give one File: "); IF f = g THEN Out.String("yes") ELSE Out.String("no") END; Out.Ln;
  f := Files.New(""); Files.GetName(f, name); Out.String("D16 Files.GetName of Files.New(''): '"); Out.String(name); Out.Char("'"); Out.Ln;
  Reals.ConvertL(1.0D20, 21, d); Out.String("D18 Reals.ConvertL(1.0D20, 21): ");
  FOR i := 20 TO 0 BY -1 DO Out.Char(d[i]) END; Out.Ln;
  Out.String("D20 Reals.Ten(-1) "); Out.Real(Reals.Ten(-1), 15); Out.String(", TenL(-1) "); Out.LongReal(Reals.TenL(-1), 24); Out.Ln;
  NEW(big); FOR k := 0 TO 39998 DO big[k] := "a" END; big[39999] := 0X;
  Out.String("D21 Strings.Length of 39999 characters: "); Out.Int(Strings.Length(big^), 0); Out.Ln;
  Out.String("D22 Math.round(1.0E10) "); Out.Int(Math.round(1.0E10), 0); Out.Ln;
  Math.ClearError; y := MathL.exp(-800.0D0); Out.String("D23 MathL.exp(-800.0D0) "); Out.LongReal(y, 24);
  Out.String(" err "); Out.Int(Math.err, 0); Math.ClearError; x := Math.exp(-200.0);
  Out.String("; Math.exp(-200.0) "); Out.Real(x, 15); Out.String(" err "); Out.Int(Math.err, 0); Out.Ln
END Checks.
