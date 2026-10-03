MODULE Pid; (* Platform.PID under -O2, where INTEGER has 2 bytes *)
IMPORT SYSTEM, Platform, Out;
PROCEDURE -AAincludeUnistd "#include <unistd.h>";
PROCEDURE -getpid(): LONGINT "(LONGINT)getpid()";
BEGIN
  IF Platform.PID = getpid() THEN Out.String("PID is the process id (expected)")
  ELSE Out.String("PID "); Out.Int(Platform.PID, 0); Out.String(", process id "); Out.Int(getpid(), 0);
    Out.String(" (expected the same)")
  END; Out.Ln
END Pid.
