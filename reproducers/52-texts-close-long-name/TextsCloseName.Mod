MODULE TextsCloseName; (* Texts.Close of a file name of 60 characters or more *)
IMPORT Texts, Out;
VAR T: Texts.Text;
BEGIN
  NEW(T); Texts.Open(T, "");
  Texts.Close(T, "a-file-name-of-sixty-characters-which-is-not-long-at-all.txt");
  Out.String("closed (expected)"); Out.Ln
END TextsCloseName.
