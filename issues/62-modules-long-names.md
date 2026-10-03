# Modules.ThisMod and ThisCommand fail for long names

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

`Heap` keeps a module's name in 20 characters and a command's in 24,
cutting longer ones, while `Modules.ThisMod` and `Modules.ThisCommand`
compare the whole name: a module or a command with a long name is not
found.

## Reproducer

`AModuleWithAVeryLongName.Mod`:

```oberon
MODULE AModuleWithAVeryLongName; (* a module name of 24 characters *)
IMPORT Out;
PROCEDURE ACommandWithAnEvenLongerName*; BEGIN Out.String("command called") END ACommandWithAnEvenLongerName;
END AModuleWithAVeryLongName.
```

`LongNames.Mod`:

```oberon
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
```

With voc at `master`:

```
$ voc -O2 AModuleWithAVeryLongName.Mod
AModuleWithAVeryLongName.Mod  Compiling AModuleWithAVeryLongName.  New symbol file.  633 chars.
$ voc -O2 LongNames.Mod -m
LongNames.Mod  Compiling LongNames.  Main program.  1014 chars.
$ ./LongNames
module not found (expected found)
(exit status 0)
```

## Cause and fix

Heap kept a module's name in an ARRAY 20 OF CHAR and a command's in an
ARRAY 24 OF CHAR, and REGMOD and REGCMD cut longer names to fit, while
Modules.ThisMod and ThisCommand compare the whole name asked for: a
module named AModuleWithAVeryLongName (24 characters) was "not found",
and so was a command of 24 characters or more.

Both arrays now have 256 characters, OPS.MaxIdLen, so any identifier
voc reads fits; Modules.ModNameLen follows.

With the fix:

```
$ ./LongNames
command called
(exit status 0)
```

The fix is `patches/0062-Heap-and-Modules-module-and-command-names-of-any-len.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
