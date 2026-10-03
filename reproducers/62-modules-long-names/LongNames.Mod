MODULE LongNames; (* Modules.ThisMod and ThisCommand of long names *)
IMPORT Modules, AModuleWithAVeryLongName, Out;
VAR m: Modules.Module; c: Modules.Command;
BEGIN
  m := Modules.ThisMod("AModuleWithAVeryLongName");
  IF m = NIL THEN Out.String("module not found (expected found)"); Out.Ln
  ELSE
    c := Modules.ThisCommand(m, "ACommandWithAnEvenLongerName");
    IF c = NIL THEN Out.String("command not found (expected called)") ELSE c END; Out.Ln
  END
END LongNames.
