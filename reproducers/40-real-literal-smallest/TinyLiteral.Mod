MODULE TinyLiteral; (* expected: an error, the literal is not 0 but rounds to 0 *)
CONST tiny = 1.0D-400;
END TinyLiteral.
