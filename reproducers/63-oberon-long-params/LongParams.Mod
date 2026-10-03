MODULE LongParams; (* Oberon.Par of a command-line argument of 256 characters or more *)
IMPORT Oberon, Out;
BEGIN
  Out.Int(Oberon.Par.text.len, 0);
  Out.String(" characters (expected 301: the argument and a blank)"); Out.Ln
END LongParams.
