# A procedure calling itself inside a WITH on its own parameter: false err 113, or C that does not compile

*This report was prepared with the help of AI (Claude, by Anthropic). The reproducers were run and the output shown is copied from those runs.*

Inside `WITH n: Pair DO` in `PROCEDURE Sum(n: Node)`, the recursive call
`Sum(n.left)` is rejected with err 113, "incompatible assignment", though
`n.left` is a `Node`. Passing the narrowed variable itself, `P(node)` inside
`WITH node: Ptr DO` in `P(node: Base)`, passes voc but produces C that gcc
rejects (incompatible pointer type).

## Reproducer

`WithRecursion.Mod`:

```oberon
MODULE WithRecursion; (* a procedure calling itself inside a WITH on its own parameter *)
IMPORT Out;
TYPE
  Node = POINTER TO NodeDesc;  NodeDesc = RECORD END;
  Pair = POINTER TO PairDesc;  PairDesc = RECORD (NodeDesc) left, right: Node END;
  Leaf = POINTER TO LeafDesc;  LeafDesc = RECORD (NodeDesc) value: INTEGER END;
VAR p, q: Pair; a, b, c: Leaf;

PROCEDURE Sum(n: Node): INTEGER;
BEGIN
  WITH n: Pair DO RETURN Sum(n.left) + Sum(n.right)     (* err 113 in voc *)
  | n: Leaf DO RETURN n.value
  END
END Sum;

BEGIN
  NEW(a); a.value := 1; NEW(b); b.value := 20; NEW(c); c.value := 300;
  NEW(q); q.left := b; q.right := c; NEW(p); p.left := a; p.right := q;
  Out.Int(Sum(p), 0); Out.String(" (expected 321)"); Out.Ln
END WithRecursion.
```

`WithCast.Mod`:

```oberon
MODULE WithCast; (* a procedure passing its own WITH-narrowed parameter to itself *)
IMPORT Out;
TYPE
  Base = POINTER TO BaseDesc;  BaseDesc = RECORD END;
  Ptr = POINTER TO PtrDesc;    PtrDesc = RECORD (BaseDesc) depth: INTEGER END;
VAR p: Ptr;

PROCEDURE P(node: Base);
BEGIN
  WITH node: Ptr DO
    IF node.depth > 0 THEN DEC(node.depth); P(node) END   (* C: incompatible pointer type *)
  END
END P;

BEGIN
  NEW(p); p.depth := 3; P(p);
  Out.Int(p.depth, 0); Out.String(" (expected 0)"); Out.Ln
END WithCast.
```

With voc at `master`:

```
$ voc -O2 WithRecursion.Mod -m
WithRecursion.Mod  Compiling WithRecursion.
  11:   WITH n: Pair DO RETURN Sum(n.left) + Sum(n.right)     (* err 113 in voc *)
                                        ^
    pos   429  err 113  incompatible assignment
  11:   WITH n: Pair DO RETURN Sum(n.left) + Sum(n.right)     (* err 113 in voc *)
                                                       ^
    pos   444  err 113  incompatible assignment
Module compilation failed.
(voc's exit status 1)
```

```
$ voc -O2 WithCast.Mod -m
WithCast.Mod  Compiling WithCast.  Main program.  1455 chars.
WithCast.c: In function ‘WithCast_P’:
WithCast.c:41:37: error: passing argument 1 of ‘WithCast_P’ from incompatible pointer type [-Wincompatible-pointer-types]
   41 |                         WithCast_P((*(WithCast_Ptr*)&node));
      |                                    ~^~~~~~~~~~~~~~~~~~~~~~
      |                                     |
      |                                     WithCast_Ptr {aka struct WithCast_PtrDesc *}
WithCast.c:36:39: note: expected ‘WithCast_Base’ {aka ‘struct WithCast_BaseDesc *’} but argument is of type ‘WithCast_Ptr’ {aka ‘struct WithCast_PtrDesc *’}
   36 | static void WithCast_P (WithCast_Base node)
      |                         ~~~~~~~~~~~~~~^~~~
WithCast.c:12:35: note: ‘WithCast_Base’ declared here
   12 |         struct WithCast_BaseDesc *WithCast_Base;
      |                                   ^~~~~~~~~~~~~
WithCast.c:20:34: note: ‘WithCast_Ptr’ declared here
   20 |         struct WithCast_PtrDesc *WithCast_Ptr;
      |                                  ^~~~~~~~~~~~
C compile and link: gcc -fPIC -g -Wno-stringop-overflow -std=gnu11 -I "<voc>/2/include"   WithCast.c   -o WithCast   -L"<voc>/lib" -lvoc-O2
-- failed: status 0, exitcode 1.
Terminated by Halt(1). 
(voc's exit status 1)
```

## Cause and fix

WITH narrows its variable by changing the type of the variable's object
(in OPP while parsing the branch, in OPV.IfStat while generating it).
When the variable is a parameter of the enclosing procedure and the
branch calls that procedure, the formal parameter is that same object,
so the call saw the narrowed type: P(n.left) inside WITH n: Pair DO in
P(n: Node) was err 113, incompatible assignment, and P(n) itself passed
the narrowed pointer with no cast, which C rejects (incompatible pointer
type). Both now keep a list of the variables narrowed by enclosing WITHs
with their declared types, and ActualParameters (OPP) and ActualPar
(OPV) use the declared type for a formal parameter on it.

With the fix:

```
$ ./WithRecursion
321 (expected 321)
(exit status 0)
```

```
$ ./WithCast
0 (expected 0)
(exit status 0)
```

The fix is `patches/0013-Check-and-pass-a-recursive-call-s-arguments-against-.patch`, a `git format-patch` of one commit.

## Environment

voc v2.1.0 at `master`, commit 9701249a (2026-09-25), built with `make all` on Fedora Linux 44, x86_64, gcc 16.2.1.
