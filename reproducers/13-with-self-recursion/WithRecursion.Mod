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
