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
