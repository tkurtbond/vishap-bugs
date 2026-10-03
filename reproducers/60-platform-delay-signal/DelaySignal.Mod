MODULE DelaySignal; (* Platform.Delay returns early when a signal arrives *)
IMPORT SYSTEM, Platform, Out;
VAR start, ms: LONGINT;
PROCEDURE -AAincludeSignal "#include <signal.h>";
PROCEDURE -AAincludeUnistd "#include <unistd.h>";
PROCEDURE -catch "struct sigaction sa = {0}; sa.sa_handler = (void (*)(int))DelaySignal_Handler; sigaction(SIGALRM, &sa, 0); alarm(1)";
PROCEDURE Handler(signal: SYSTEM.INT32); (* only so that the signal does not end the program *)
END Handler;

BEGIN
  catch;                                  (* SIGALRM after 1 s *)
  start := Platform.Time(); Platform.Delay(3000); ms := Platform.Time() - start;
  IF ms >= 3000 THEN Out.String("slept 3 s or more") ELSE Out.String("slept "); Out.Int(ms DIV 100 * 100, 0); Out.String(" ms") END;
  Out.String(" (expected 3 s or more)"); Out.Ln
END DelaySignal.
