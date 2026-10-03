# Where voc does otherwise, without a bug

*Prepared with the help of AI (Claude, by Anthropic). Every observation below
was made by running `differences/Checks.Mod` or `differences/HaltOrder.Mod`
with voc at `master` (commit 9701249a), or by reading voc's source there.*

While voc was used to cross-check Peaseblossom, a number of things were
noted as differences between voc and what one might expect. Looked at
closely, those below are not bugs, so they have no issue and no patch. The
first part lists things that were believed wrong and turn out to be right.
The second lists choices voc makes that a program may need to know about,
where another implementation could reasonably do otherwise. The third is a
fault in code that voc's build leaves out. An entry that
`differences/Checks.Mod` checks has the same number in its output.

`differences/Checks.Mod` is compiled with `voc -O2 Checks.Mod -m`; with
voc at `master` it prints:

```
D1  Out.Int(MIN(HUGEINT), 0) [-9223372036854775808], width 24 [    -9223372036854775808]
D2  Strings.Pos in a full ARRAY 4 with no 0X: 'cd' at 2, 'x' at -1
D3  Math.sinh(89.0)  2.24480639E+38 err 0
D4  Math.small's bits 00800000
D5  Texts.WriteDate of 2026-10-03: 03.10.26 00:00:00
D6  Platform.getEnv of HOME into an ARRAY 4: /ho
D7  Texts with positions 1000 in a text of 5: saved 2, length after the insertion 6
D9  MathL.tan(pi/2)  2.0234083817726248D+007 err 0
D10 Math.round of 2.5, -2.5, 3.5: 3 -3 4
D11 Modules.GetArg(5, a) with 1 argument leaves a: keep
D14 two Files.Old of one file give one File: yes
D16 Files.GetName of Files.New(''): ''
D18 Reals.ConvertL(1.0D20, 21): 001215752192000000000
D20 Reals.Ten(-1)  1.00000000E+00, TenL(-1)  1.0000000000000000D+001
D21 Strings.Length of 39999 characters: 32767
D22 Math.round(1.0E10) 1410065408
D23 MathL.exp(-800.0D0)  0.0000000000000000D+000 err 0; Math.exp(-200.0)  0.00000000E+00 err 11
```

`differences/HaltOrder.Mod` registers a finalizer and calls `HALT(3)`; with
its standard output and standard error kept apart:

```
$ ./HaltOrder > out.txt 2> err.txt; echo $?
3
$ cat out.txt
finalizer ran
Terminated by Halt(3). 
$ cat err.txt
$
```

## Right after all

**D1. Out.Int of the smallest 64-bit integer.** `Out.Int(MIN(HUGEINT), n)`
writes `-9223372036854775808` correctly, padded to `n` like any other
number. (`Texts.WriteInt` gets the padding wrong: issue 53.)

**D2. Strings.Pos stops at the end of the array.** `Pos` finds a pattern in
an array that its string fills, with no 0X, and does not read beyond it.
(`Strings.Cap` did read beyond, issue 57, and `Pos` with a negative start
traps, issue 22.)

**D3. Math.sinh and Math.cosh are not clipped.** They are finite up to
about 89.4 and report no error below it. `HypInvTrigClipped` comes only
from `arcsinh` and `arccosh` (issue 56).

**D4. Math.small is exact.** It is written `1/8.50705917E37`, but as a
`REAL` it is 2^-126 exactly, the smallest normal number. (`MathL.small` was
0: issue 41.)

**D5. Texts.WriteDate writes a two-digit year.** The packed date of
`Oberon.GetClock` and `Files.GetDate` holds the year MOD 100 (bits 9 and
up), so there is no more to write.

**D6. Platform.getEnv does not overrun its array.** It copies the value
with `COPY`, which stops at the end of `val`: `HOME` into an `ARRAY 4` is
`/ho`.

**D7. Texts takes positions beyond the end of a text.** `OpenReader`,
`Save`, `Insert` and `Delete` treat a position past the end as the end.

**D8. C `int` results declared LONGINT are harmless.** voc's external
declarations of C functions (`PROCEDURE -name ... "C text"`) give C's `int`
results and parameters the types `INTEGER` or `LONGINT`, which under `-OC`
are wider than `int`. That would be wrong for a real call on a 32-bit
machine, but these procedures are C macros: the C text is inserted where
the procedure is called, and the C compiler converts the values.

**D9. MathL.tan never reports IllegalTrig.** `MathL.tan` reports
`IllegalTrig` when the cosine is below `miny` (1/MAX(LONGREAL), about
5.6E-309), which the cosine of no `LONGREAL` is: the smallest, at the
`LONGREAL` nearest pi/2, is about 6.1E-17. `Math.tan` has no such check.
So both return a large finite number near a pole, as the C library does.
(How far off that number is at `master` is issues 03 and 38. With the
series, `MathL.tan(pi/2)` is 1.6331326887777166E16, the C library's
1.633123935319537E16: at a pole the last bits of the reduced argument
decide the result, and voc's reduction keeps fewer of them than the C
library's.)

**D10. Math.round rounds halves away from zero:** 2.5 to 3, -2.5 to -3.

## Choices voc makes

**D11. Modules.GetArg leaves `val` alone for a missing argument.** With `n`
outside 0..ArgCount-1, `val` keeps what it held, so a caller that does not
check `ArgCount` sees its previous value again.

**D12. Halt and failed assertions write to standard output.** Their message
("Terminated by Halt(3).", and the trap messages such as "NIL access.") goes
to standard output, mixed with the program's own output, not to standard
error.

**D13. Finalizers run before Halt's message.** A finalizer registered with
`Heap.RegisterFinalizer` runs before "Terminated by Halt(n)." is written.

**D14. Two Files.Old calls for one file give one File.** `Files.Old` returns
the `File` already open for that file, so a write through one is at once
seen through the other.

**D15. In.Open seeks standard input back to its start.** `In.Open` calls
`Platform.Seek(StdIn, 0, SeekSet)`, which starts a file over, but does
nothing, and reports no error, for a pipe or a terminal.

**D16. A new file has no name until it is registered.** `Files.GetName` of
`Files.New("")` is the empty string, not the name of the temporary file
holding it.

**D17. Modules.MainStackFrame is the address of `main`'s `argv`.** The
`__INIT` macro passes `&argv`, so `MainStackFrame` is the address of that
parameter of C's `main`, not of a stack frame as such.

**D18. Reals.ConvertL goes through LONGINT.** It converts `x` to a
`LONGINT` (in two parts under `-O2`) before writing its digits, so for an
`x` beyond that range, about 9.2E18 under `-OC` and 2.1E18 under `-O2`, the
digits are wrong: `ConvertL(1.0D20, 21, d)` gives `001215752192000000000`.

**D19. Reals.ConvertH and ConvertHL write the bytes least significant
first.** Each byte is two hexadecimal digits, high digit first, but the
bytes are in the order a little-endian machine keeps them in memory, on any
machine (as Ofront did).

**D20. Reals.Ten and TenL are for exponents of 0 and up.** `Ten(-1)` is 1.0
and `TenL(-1)` is 10.0. Their callers in voc pass `e >= 0`. (With the
series' patch 36, `TenL` gives 10^e for any `e`.)

**D21. Strings works in INTEGER.** Lengths and positions are `INTEGER`,
which under `-O2` has 16 bits: `Strings.Length` of a string of 39999
characters is 32767.

**D22. Math.round of a number out of range wraps.** `Math.round(1.0E10)` is
1410065408 under `-O2`, the low 32 bits of 10^10.

**D23. MathL does not report Underflow.** `MathL.exp` of a very negative
number is 0 and leaves `Math.err` alone, where `Math.exp` reports
`Underflow`.

## Not built

**D24. ethReals.ExpoL's 64-bit branch.** When `LONGINT` has 8 bytes,
`ethReals.ExpoL` returns `ASH(SYSTEM.VAL(LONGINT, x), -50) MOD 256`, where
the exponent is `ASH(..., -52) MOD 2048`. That branch is taken only under
`-OC`, and `make all` builds the s3 library, `ethReals` with it, only for
`-O2`, so no installed voc runs it. (Under `-O2`, `ethReals` has the bug of
issue 67.)
