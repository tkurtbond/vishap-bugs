# The collector frees an object referenced only from a callee-saved register

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Because voc compiles its C without optimization, `Heap.GC`'s "register
pressure" locals do not force the callee-saved registers onto the stack. A
pointer that gcc keeps only in `rbx` or `r12`-`r15`, as it does while
evaluating `Check(Make("a"), Make("b"), Make("c"))` where `Make` allocates,
is not a root, and its block is freed while still in use. How many calls
are hit depends on the allocation pattern: 2 in a million with voc built
from `master` as below, and 752 with another build of v2.1.0 (commit
552eade0).

## Reproducer

`GcRepro.Mod`:

```oberon
MODULE GcRepro; (* voc's GC frees a pointer held only in a callee-saved register *)

IMPORT Out;

TYPE String = POINTER TO ARRAY OF CHAR;

VAR bad, i: LONGINT;

PROCEDURE Make(s: ARRAY OF CHAR): String;
  VAR p: String;
BEGIN NEW(p, LEN(s)); COPY(s, p^); RETURN p
END Make;

PROCEDURE Check(a, b, c: String);
BEGIN
  IF (a^ # "aaaaaaaaaaaa") OR (b^ # "bbbbbbbbbbbb") OR (c^ # "cccccccccccc") THEN
    INC(bad);
    IF bad <= 3 THEN
      Out.String("a = "); Out.String(a^); Out.String(", b = "); Out.String(b^);
      Out.String(", c = "); Out.String(c^); Out.Ln
    END
  END
END Check;

BEGIN
  bad := 0;
  FOR i := 1 TO 1000000 DO Check(Make("aaaaaaaaaaaa"), Make("bbbbbbbbbbbb"), Make("cccccccccccc")) END;
  Out.String("calls with a corrupted argument: "); Out.Int(bad, 0); Out.String(" of 1000000"); Out.Ln
END GcRepro.
```

With voc at `master`:

```
$ voc -OC GcRepro.Mod -m
GcRepro.Mod  Compiling GcRepro.  Main program.  1667 chars.
$ ./GcRepro
a = aaaaaaaaaaaa, b = bbbbbbbbbbbb, c = ��������
a = aaaaaaaaaaaa, b = bbbbbbbbbbbb, c = ��������
calls with a corrupted argument: 2 of 1000000
(exit status 0)
```

## Cause and fix

The collector finds roots on the stack only. GC's register pressure
(i0 .. i23) is meant to push the callee-saved registers into its frame,
but voc compiles its C without optimization, so those locals are plain
stack slots and the registers stay where they are. A pointer that the C
compiler keeps only in rbx or r12-r15 while it evaluates a call whose
arguments allocate, as gcc does for Check(Make("a"), Make("b")), was not
marked, and its block was freed while in use: the reproducer corrupted
752 of 1000000 calls on x86_64 Linux with gcc.

GC now calls __SAVE_REGISTERS() (SYSTEM.h) first: __builtin_unwind_init()
with gcc and clang, which saves every callee-saved register in the
prologue, and setjmp into a local jmp_buf elsewhere.

With the fix:

```
$ ./GcRepro
calls with a corrupted argument: 0 of 1000000
(exit status 0)
```

The fix is `patches/0014-Heap.GC-store-the-callee-saved-registers-before-scan.patch`, a `git format-patch` of one commit.

It changes lines that patch 0009 (CAP changes characters that are not lower-case letters) also changes, and is made to apply after it.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
