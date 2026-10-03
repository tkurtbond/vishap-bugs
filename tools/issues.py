# Per-issue text for the vishap-bugs repository: title (the bug, as an
# issue states it) and summary (what a user sees).  The reproducer, the
# transcripts and the cause and fix are added by gen.py.

ISSUES = {
1: ("Integral LONGREAL literals >= 2^31 and constant ENTIER >= 2^31 halt the compiler under -OC",
"""Under `-OC`, an integral `LONGREAL` literal of 2^31 or more (`2147483648.0D0`,
`1.0D10`) and a constant `ENTIER` of such a value (`ENTIER(3000000000.5D0)`)
stop the compiler with `Halt(-8)`, "Value out of range". Both come from the
same place: the compiler's own `ENTIER`, which is 32 bits wide."""),

2: ("Real literals are not correctly rounded",
"""The scanner converts decimal real literals with a sequence of rounded
operations, so many literals become a neighbouring double: `1.1D3` is
1100.0000000000002, `123.456D0` is 123.45600000000002, `1.0D23` is
1.0000000000000001D23. Constant folding and constant comparisons see these
values."""),

3: ("Real constants lose digits in the generated C",
"""A real constant is written into the C file with 15 or 16 significant
digits, so the C compiler often reads back a different value: a folded
`1.0D0 / 3.0D0` is not equal to the same division done at run time. A very
small constant can come out as 0 (MathL's `miny`, so `MathL.power(0.0D0,
3.0D0)` is about 2.5D-5, not 0). `Math`'s sin and tan, which reduce their
argument by multiples of the constants `pi` and `piByTwo`, so of what is
left of them in C, are hundreds of units in the last place off, and near
a multiple of pi/2 up to a million: `Math.tan(1.5707964)` is 3.0E14, not
-2.29E7."""),

4: ("REAL literals of 1.0E38 or more and LONGREAL literals of 1.0D308 or more are \"number too large\"",
"""`3.4E38` and `1.7D308` are within range (`MAX(REAL)` is about 3.40282E38,
`MAX(LONGREAL)` about 1.79769D308) but are rejected with err 203, "number
too large". No value near the top of either range can be written as a
literal."""),

5: ("MAX(LONGREAL) is not the largest LONGREAL, and a folded MAX(REAL) is not the stored one",
"""`MAX(LONGREAL)` (and `MathL.large`) is 7FEFFFFFCCCCCCD3, about
1.7976929634D308, not 7FEFFFFFFFFFFFFF. `MAX(REAL)` folded by the compiler
is 3.40282346D38, slightly below the largest REAL, so it is not equal to
`MAX(REAL)` stored in a `REAL` variable."""),

6: ("SHORT of a LONGREAL is not rounded to REAL inside an expression",
"""`LONG(SHORT(x))` and `SHORT(x) * 1.0D0` are `x` itself, not `x` rounded to
`REAL`: the narrowing happens only when the result is stored in a `REAL`
variable."""),

7: ("DIV and MOD give wrong results for a 64-bit dividend near MIN or MAX, and a constant product of -2^63 is rejected",
"""Under `-OC`, `MIN(LONGINT) DIV 2` is 4611686018427387903 (positive),
`(MIN(LONGINT) + 1) DIV 2` and `MAX(LONGINT) DIV (-2)` are positive, and
`MIN(LONGINT) MOD (-3)` is 2: the run-time `SYSTEM_DIV`/`SYSTEM_MOD`
overflow. The compiler's constant folder uses them to check a product for
overflow, so it also rejects the constant `(-4611686018427387904) * 2`,
which is exactly -2^63 and fits, with err 204, "product too large"."""),

8: ("Constant MIN(HUGEINT) DIV (-1) crashes the compiler with SIGFPE",
"""Folding `MIN(HUGEINT) DIV (-1)`, whose value does not fit, kills the
compiler with a floating point exception instead of reporting an error."""),

9: ("CAP changes characters that are not lower-case letters",
"""`CAP` clears bit 5, so `CAP("7")` is 17X, `CAP("{")` is `[` and `CAP("`")`
is `@`, at run time and in constants alike."""),

10: ("ABS of a 64-bit argument with side effects is cut to 32 bits",
"""Under `-OC`, `ABS(a[Next()])` with `a[1] = -5000000000` is 705032704: when
the argument has side effects, the 64-bit and 32-bit helper functions are
called the wrong way round."""),

11: ("A row of a multi-dimensional open array passed as an open array ignores the row stride",
"""Inside a procedure with `a: ARRAY OF ARRAY OF INTEGER`, passing `a[r]` to an
`ARRAY OF INTEGER` parameter passes `&a[r]` rather than `&a[r * LEN(a, 1)]`,
so the callee sees elements r .. r + LEN(a, 1) - 1 of the flat data instead
of row r. The same call on a fixed array is right."""),

12: ("A nested procedure gets garbage inner lengths for its parent's multi-dimensional open array",
"""When a nested procedure uses an enclosing procedure's parameter `x: ARRAY OF
ARRAY OF T`, the generated C copies the outer length twice and never the
inner one, so in the nested procedure `LEN(x, 1)` and every `x[i, j]` use an
uninitialized length: a NIL access trap or a wrong element."""),

13: ("A procedure calling itself inside a WITH on its own parameter: false err 113, or C that does not compile",
"""Inside `WITH n: Pair DO` in `PROCEDURE Sum(n: Node)`, the recursive call
`Sum(n.left)` is rejected with err 113, "incompatible assignment", though
`n.left` is a `Node`. Passing the narrowed variable itself, `P(node)` inside
`WITH node: Ptr DO` in `P(node: Base)`, passes voc but produces C that gcc
rejects (incompatible pointer type)."""),

14: ("The collector frees an object referenced only from a callee-saved register",
"""Because voc compiles its C without optimization, `Heap.GC`'s "register
pressure" locals do not force the callee-saved registers onto the stack. A
pointer that gcc keeps only in `rbx` or `r12`-`r15`, as it does while
evaluating `Check(Make("a"), Make("b"), Make("c"))` where `Make` allocates,
is not a root, and its block is freed while still in use. How many calls
are hit depends on the allocation pattern: 2 in a million with voc built
from `master` as below, and 752 with another build of v2.1.0 (commit
552eade0)."""),

15: ("Files keeps relative names and later renames by them from another directory: Halt(99)",
"""`Files.New` and `Files.Old` store the name as given. When the same file is
registered again later, `Files` renames the open `File` by that stored name,
resolved against the directory current then; after a change of directory
this fails with ENOENT and the program stops with "Couldn't rename previous
version of file being registered" and `Halt(99)`."""),

16: ("Files.Delete of a file the program has open reports failure but deletes it",
"""`Files.Delete` of a file that is still open returns `res = 2` although the
name is gone afterwards."""),

17: ("Files.Rename of an open file leaves the open File with the old name: Halt(99) later",
"""After `Files.Rename` of a file the program has open, the open `File` keeps
the old name (the TODO in `Rename`). Registering a new file under the new
name then tries to rename the open file by its old, gone name and stops the
program with "Couldn't rename previous version of file being registered",
`Halt(99)`."""),

18: ("Strings.Insert at a position past the end does nothing",
"""`Strings.Insert("XYZ", 10, s)` with `s = "abc"` leaves `s` as it was; Oakwood
says the source is appended. `Insert` calls `Append` with its arguments the
wrong way round."""),

19: ("Strings.Replace deletes pos + Length(source) characters",
"""`Strings.Replace("XY", 3, s)` with `s = "abcdefgh"` gives `abcXY`, not
`abcXYfgh`: it deletes `pos + Length(source)` characters instead of
`Length(source)`."""),

20: ("Strings.Append and Insert leave no 0X when the result is too long",
"""Oakwood requires a result too long for `dst` to be cut short so that `dst`
always ends with 0X. `Append` fills `dst` to its last element and leaves no
0X, and `Insert` leaves none either."""),

21: ("Strings.Extract into a small dest writes past its end",
"""`Strings.Extract("abcdefgh", 1, 6, d)` with `d: ARRAY 4 OF CHAR` stops with an
index trap (or, without `-x`, writes past `d`): the part is not cut short to
leave room for the 0X."""),

22: ("Strings.Pos with a negative start is an index trap",
"""`Strings.Pos("c", "abc", -2)` stops with "Index out of range": it indexes
`s[pos]` with the negative `pos`. `Insert` and `Delete` already treat a
negative position as 0."""),

23: ("Files.ReadString and Files.ReadLine write past the end of the array",
"""`Files.ReadString` and `Files.ReadLine` store every character of the value
with no bound, so a value longer than the array is an index trap (or, with
`-x` off, a write past it)."""),

24: ("A HUGEINT variable cannot be passed to In.HugeInt",
"""`In.HugeInt(h)` with `h: HUGEINT` is err 123, "type of actual parameter is
not identical with that of formal VAR-parameter". `HUGEINT` is a type of its
own, but a symbol file records an 8-byte integer only by its size and reads
it back as `SYSTEM.INT64`, so an exported `VAR x: HUGEINT` parameter is a
`SYSTEM.INT64` one to importers."""),

25: ("In.LongInt reads hexadecimal digits without the H",
"""Given `12AB`, `In.LongInt` returns 4779 with `Done` TRUE. In Oakwood's
format hexadecimal digits need a trailing `H`; without it the input is not a
number."""),

26: ("In.Real and In.LongReal read the rest of the line, cut at 15 characters",
"""`In.LongReal` reads the rest of the line into a 16-character buffer: a
number longer than 15 characters is cut, and the rest is left for the next
read; a second number on the same line is lost; and `Done` is TRUE whatever
the line held."""),

27: ("In.Name is not implemented",
"""`In.Name` stops the program with `HALT(99)` ("Not implemented")."""),

28: ("Strings.StrToReal and StrToLongReal ignore an exponent with a + sign",
"""`Strings.StrToLongReal("2.5E+2", d)` gives 2.5, not 250: only a `-` is accepted
after the `E`."""),

29: ("Strings.StrToReal and StrToLongReal are not correctly rounded",
"""`Strings.StrToLongReal("0.3", d)` does not give the double nearest 0.3, nor
`"1.0E23"` the double nearest 10^23: the value is built digit by digit with
rounding at every step."""),

30: ("Out.Real and Out.LongReal write a wrong exponent when rounding carries",
"""When rounding the digits carries into a new leading digit, the exponent is
not incremented: `1.0E37` is written `1.0E+36`, `1.0D300` `1.0D+299`, and the
double just below 1.0 `1.0D-001`."""),

31: ("Out.LongReal writes a subnormal number as 0",
"""Any subnormal `LONGREAL` (4.9D-324 up to 2.2D-308) is written as
`0.0D+000`."""),

32: ("Out.LongReal does not write correctly rounded digits",
"""`Out.LongReal` makes the digits by scaling with rounded powers of ten, so
they are often not the digits of the number: 1/7 is written
1.4285714285714284D-001, not ...285. Of 2000 random doubles written with 17
significant digits, 1677 did not read back as the same double, though 17
digits always suffice. (`Out.Real` goes through the same code.)"""),

33: ("VT100 cuts a count of 10 or more to its first digit",
"""`VT100.CUU(12)` sends `ESC[1A`, moving up one line, not twelve: the count is
converted into an `ARRAY 2 OF CHAR`. Two-argument sequences cut a count at 4
digits (`CUP(12345, 67)` sends `ESC[1234;67H`)."""),

34: ("VT100.DSR sends 6 whatever its argument",
"""`VT100.DSR(5)`, the device status report, sends `ESC[6n` (the cursor
position report)."""),

35: ("VT100.SetAttr cuts its argument at 13 characters",
"""`VT100.SetAttr("38;5;123;48;5;45m")` sends `ESC[38;5;123;48;5;` without the
final `m`, so the terminal takes the following text as part of the
sequence."""),

36: ("Reals.TenL is not correctly rounded",
"""`Reals.TenL(e)` is not the double nearest 10^e for 252 of the exponents
0..308 (`TenL(33)` is 46C8A6E32246C99D, not ...9C; `TenL(300)` is four units
in the last place high), and a negative `e` gives 10."""),

37: ("Features.md says SET has 64 bits under -OC",
"""`doc/Features.md`'s table of sizes says `SET` has 64 bits under `-OC`. Since
commit 7f4b284a ("Correct set size in component pascal compatability mode",
2019) it has 32 bits under both size models (`OPM.Mod`: `SetSize := 4`);
`SYSTEM.SET64` is the 64-bit set."""),

38: ("Math.sincos and MathL.sincos give a cosine that is never negative",
"""`sincos` computes the cosine as `sqrt(1 - sin(x)^2)`, so for x in (pi/2,
3pi/2) it has the wrong sign: `Math.sincos(2.0)` gives cos 0.416, where cos(2)
is -0.416. `MathL.tan` is computed from `sincos`, so it has the wrong sign
there too, and near a pole it is far off: `MathL.tan` of the `LONGREAL`
nearest pi/2 is 2.02E7, not 1.633E16."""),

39: ("Math.succ and Math.pred do not give the neighbouring numbers",
"""For a negative number `succ` moves down and `pred` up (`Math.succ(-1.0)` is
-1.0000001); at a power of two `pred` skips a number (`Math.pred(1.0)` is 1 -
2^-23, not 1 - 2^-24); `succ(0.0)` is 2^-23 rather than the smallest
denormal. The same holds for `MathL`."""),

40: ("Real literals below the smallest normal number are \"number too large\"",
"""A `REAL` literal below about 1.0E-37 and a `LONGREAL` literal below about
1.0D-307 are rejected with err 203, "number too large", so even the smallest
normal numbers, 1.17549435E-38 and 2.2250738585072014D-308, cannot be
written, nor any denormal, nor `0.0D-400`."""),

41: ("MathL.small is 0",
"""`MathL.small`, meant to be the smallest normal `LONGREAL`, 2^-1022, is 0.0 in
the compiled library."""),

42: ("Math.exponent and MathL.exponent of a denormal number are wrong",
"""Every denormal gets the exponent -127 (`MathL`: -1023): `Math.exponent` of
2^-149 is -127, not -149."""),

43: ("Texts writes an infinity as NaN",
"""`Texts.WriteReal`, `WriteLongReal` and `WriteRealFix` write " NaN" for
positive and negative infinity."""),

44: ("Texts writes a subnormal number as 0",
"""`Texts.WriteReal` of 2^-149 (1.4E-45) and `Texts.WriteLongReal` of 2^-1074
(4.9D-324) write `0`."""),

45: ("Texts.WriteRealFix drops decimals and traps on numbers with more than 9 digits before the point",
"""`Texts.WriteRealFix(W, 1234.5, 12, 6)` writes `1234.50008`: decimals are
dropped to stay within 9 digits, and the digits beyond REAL's precision are
noise. `WriteRealFix(W, 0.0006, 8, 3)` writes `0.0000`. A number with more than
9 digits before the point, such as 1.0E10, stops the program with "Index out
of range"."""),

46: ("Texts.Scan stops the program with HALT(40) on a large exponent",
"""`Texts.Scan` of a real number whose exponent is above 38 (E) or 308 (D)
stops the program with `HALT(40)`, even when the number is in range
(`0.001D310` is 1.0D307); a number whose negative exponent is beyond those is
read as 0 even when it is in range (`1000.0D-310`)."""),

47: ("Math.sqrt and MathL.sqrt are not correctly rounded",
"""`MathL.sqrt(2.0D0)` is 1.4142135623730949, not 1.4142135623730951, and
`Math.sqrt(1.0)` is 0.99999994. Of 3007 random doubles `MathL.sqrt` got 2029
wrong, and of 3003 random REALs `Math.sqrt` got 746 wrong; IEEE 754 requires
the square root correctly rounded."""),

48: ("Math and MathL: sin, cos and tan of a large argument are 0",
"""`Math.sin` and `Math.cos` return 0 and set `Math.err` to LossOfAccuracy for
an argument of 9099 or more, `Math.tan` above 6434, and `MathL.sin` and
`MathL.cos` (and so `MathL.tan`) for one of 210828714 or more:
`Math.sin(10000.0)` is 0, not -0.3056. Every finite real has a sine."""),
49: ("Texts: storing a text loaded from a file stops with a NIL access",
"""A text opened from an Oberon text file (one that `Texts.Close` or
`Texts.Store` wrote) has no fonts: every run's `fnt` is NIL. Storing it
again with `Texts.Close` or `Texts.Store`, or inserting into it where runs
are merged, stops the program with a NIL access."""),
50: ("Texts.Store writes CR LF of a plain text as two line ends",
"""`Texts.Open` of a plain text file reads CR LF as one line end, but
`Texts.Store` (and so `Texts.Close`) writes it as CR CR: a file with CR LF
line ends, opened and closed, has twice as many lines when it is opened
again."""),
51: ("Texts.Save and Copy stop with a NIL access on an element that is not copied",
"""`Texts.Save`, and `Texts.Copy` of a buffer, copy each element by sending
it a `CopyMsg`. If the element's handler makes no copy, a NIL goes into the
buffer and the program stops with a NIL access."""),
52: ("Texts.Close traps on a file name of 60 characters or more",
"""`Texts.Close` makes the backup file's name, the name followed by
`.Bak`, in an `ARRAY 64 OF CHAR`: a name of 60 characters or more, which
`Files` takes, stops the program with an index out of range."""),
53: ("Texts.WriteInt of MIN(SYSTEM.INT64) ignores the width",
"""`Texts.WriteInt(W, MIN(SYSTEM.INT64), n)` always writes
` -9223372036854775808`, with one blank, whatever `n` is: too few blanks
for a wide field, and one too many for `n` = 0."""),
54: ("Math and MathL: fraction, ulp and scale are wrong for denormal numbers",
"""`fraction`, `ulp` and `scale` take every number to be normal.
`Math.fraction` of a denormal number is wrong, `Math.scale` gives the
smallest normal number for any result below the normal range, and `ulp`
of a denormal number is the smallest normal number or 0. The same holds
for `MathL`."""),
55: ("Math.exp and MathL.exp give 0 where the result is a denormal number",
"""`Math.exp(x)` is 0, and sets `Math.err` to Underflow, for any `x` below
about -88.7, though `exp(x)` is a denormal `REAL` down to about -103.3.
`MathL.exp(x)` is 0 below about -709.8, though the result is a denormal
`LONGREAL` down to about -744.4."""),
56: ("Math and MathL: arcsinh and arccosh of a large argument are wrong",
"""For an argument above about 9.2E18 (`REAL`) or 6.7E153 (`LONGREAL`),
`arcsinh` and `arccosh` report HypInvTrigClipped and return the same
value, ln(sqrt(MAX)), whatever the argument. Both functions are finite for
every finite argument, and there they are ln(2x)."""),
57: ("Strings.Cap runs off the end of an array with no 0X",
"""`Strings.Cap(s)` looks for the 0X that ends `s` with no bound, so a
string that fills its array traps with an index out of range (or, with
index checks off, changes memory beyond the array)."""),
58: ("Platform.MTimeAsClock (Files.GetDate) reads past its LONGINT under -O2",
"""Under `-O2`, `Platform.MTimeAsClock`, which `Files.GetDate` calls,
passes `localtime` the address of a 4-byte `LONGINT` as a `time_t *`, so
`localtime` reads 4 bytes beyond it. On Linux they happened to be 0 and
the date was right; on FreeBSD amd64 and OpenBSD i386 `localtime` returned
NULL and `Files.GetDate` stopped the program with a NIL access."""),
59: ("Platform.Write loses what a partial write leaves",
"""`Platform.Write` makes one `write(2)` call and reports success if it
does not fail, though `write` may write fewer bytes than asked, to a pipe
or when a signal arrives. The rest is lost without an error. `Out`,
`Files` and `Console` write through `Platform.Write`."""),
60: ("Platform.Delay returns early when a signal arrives",
"""`Platform.Delay(ms)` makes one `nanosleep` call, which returns early
when a signal is caught, so the program sleeps less than `ms`."""),
61: ("Platform.PID is wrong under -O2, and temporary file names can collide",
"""`Platform.PID` is an `INTEGER`, 16 bits under `-O2`, so a process id
above 32767 wraps. `Files` builds temporary file names from `PID`, and
writes no digits for a negative one, so two programs in one directory can
make the same temporary names."""),
62: ("Modules.ThisMod and ThisCommand fail for long names",
"""`Heap` keeps a module's name in 20 characters and a command's in 24,
cutting longer ones, while `Modules.ThisMod` and `Modules.ThisCommand`
compare the whole name: a module or a command with a long name is not
found."""),
63: ("Oberon.Par cuts command-line arguments to 255 characters",
"""`Oberon` copies each command-line argument into an
`ARRAY 256 OF CHAR` on its way to `Oberon.Par.text`, so an argument of
256 characters or more is cut."""),
64: ("Oberon.Log echoes text that is deleted or changed",
"""The notifier that echoes text appended to `Oberon.Log` on standard
output echoes on every change to the Log: after `Texts.Delete` it writes
the text that follows the deleted part (or a 0X), and after
`Texts.ChangeLooks` the changed text again."""),
65: ("Texts.Scan traps on a number of 32 digits or more",
"""`Texts.Scan` keeps a number's digits in an `ARRAY 32 OF CHAR` with no
bound, so a number of 32 digits or more, its integer part and decimals
together, stops the program with an index out of range: pi written to 36
decimal places is enough."""),
66: ("Texts.Scan does not read real numbers correctly rounded",
"""`Texts.Scan` computes a real number's value digit by digit in floating
point, so it is often a unit or more in the last place off: `1.06E7` is
read as 10599999.0, and `0.3D0` is not the `LONGREAL` nearest 0.3. Of
2000 random `REAL` numerals 636 are read wrong, and of 1000 `LONGREAL`
ones 869."""),
67: ("ethReals reads the wrong half of a LONGREAL, so ethStrings.RealToStr writes nonsense",
"""`ethReals` keeps the offsets of a `LONGREAL`'s high and low 32 bits in
the variables `H` and `L`, which nothing sets, so both are 0. On a
little-endian machine `ExpoL`, `SetExpoL`, `RealL` and `IntL` then take
the low half for the high one, and `ethStrings.RealToStr`, which uses
them, writes nonsense: `RealToStr(12345.678D0, s)` gives
`0.000000000000005D+042`, and `RealToStr(3.0D0, s)` gives `0`."""),
}

# Series numbers each patch needs applied first, for its code to apply or work.
NEEDS = {
3: [2], 4: [2], 5: [3], 17: [15], 29: [28], 32: [30, 31],
40: [2, 4], 41: [40, 3], 54: [42], 55: [54], 66: [65],
}

# Patches that change the same lines as an earlier one, without needing
# what it does: applied alone (without the earlier one) they need
# rebasing, which the standalone branches show.
OVERLAPS = {
3: [1], 14: [9], 20: [18], 54: [48], 61: [15], 65: [46],
}

# Transcripts from another system, for an issue that does not show on
# Linux: (system, transcript at master, transcript with the fix).
ELSEWHERE = {
58: ("FreeBSD 15.1-RELEASE amd64, clang 19.1.7, voc built there at the same commits",
"""$ voc -O2 FileDate.Mod -m
FileDate.Mod  Compiling FileDate.  Main program.  1405 chars.
$ ./FileDate
Terminated by Halt(-10). NIL access.
(exit status 246)""",
"""$ ./FileDate
now                2026-10- 3 15:59
file's date        2026-10- 3 15:59 (expected the same, to the minute)
(exit status 0)"""),
}
