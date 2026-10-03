MODULE WritePartial; (* Platform.Write is a single write(2): a partial one is lost *)
IMPORT SYSTEM, Platform;
CONST N = 1000000;
VAR buf: POINTER TO ARRAY N OF CHAR; i: LONGINT; res: Platform.ErrorCode;
PROCEDURE -AAincludeSignal "#include <signal.h>";
PROCEDURE -AAincludeUnistd "#include <unistd.h>";
PROCEDURE -catch "struct sigaction sa = {0}; sa.sa_handler = (void (*)(int))WritePartial_Handler; sigaction(SIGALRM, &sa, 0); alarm(1)";
PROCEDURE Handler(signal: SYSTEM.INT32); (* only so that the signal does not end the program *)
END Handler;

BEGIN
  NEW(buf); FOR i := 0 TO N - 1 DO buf[i] := "x" END;
  catch;                   (* a signal arrives while the reader is not yet reading *)
  res := Platform.Write(Platform.StdOut, SYSTEM.ADR(buf^), N);
  IF res # 0 THEN Platform.Exit(1) END
END WritePartial.
