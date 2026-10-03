MODULE InName; (* In.Name is not implemented *)
IMPORT In, Out;
VAR n: ARRAY 64 OF CHAR;
BEGIN
  In.Name(n); Out.String(n); Out.String(" (expected dir/file.txt)"); Out.Ln
END InName.
