MODULE HaltOrder; (* where Halt's message goes, and when finalizers run *)
IMPORT SYSTEM, Heap, Out;
VAR p: POINTER TO RECORD END;
PROCEDURE Finalize(o: SYSTEM.PTR); BEGIN Out.String("finalizer ran"); Out.Ln END Finalize;
BEGIN
  NEW(p); Heap.RegisterFinalizer(p, Finalize);
  HALT(3)
END HaltOrder.
