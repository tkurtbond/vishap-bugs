MODULE VT100SetAttr; (* SetAttr cuts its argument at 13 characters *)
IMPORT VT100, Out;
BEGIN
  VT100.SetAttr("38;5;123;48;5;45m"); Out.String(" (expected ESC[38;5;123;48;5;45m)"); Out.Ln;
  VT100.SetAttr("0m")
END VT100SetAttr.
