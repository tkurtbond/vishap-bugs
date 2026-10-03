#!/bin/sh
# run.sh VOCDIR: run the checks behind the counts in issues 32, 47 and 48
# with the voc installed in VOCDIR, comparing with the C library (Linux:
# libm.so.6, for trigcheck.py and sqrtcheckr.py).
[ $# -eq 1 ] || { echo "usage: $0 VOCDIR" >&2; exit 2; }
V=$(cd "$1" && pwd); C=$(cd "$(dirname "$0")" && pwd)
export PATH=$V/bin:$PATH LD_LIBRARY_PATH=$V/lib
d=$(mktemp -d); cd "$d" && cp "$C"/*.Mod .
voc -OC OutDigits.Mod -m >/dev/null && ./OutDigits < "$C/OutDigits.vals" > OutDigits.out &&
  { printf 'Out.LongReal (issue 32): '; python3 "$C/outcheck.py" "$C/OutDigits.vals" OutDigits.out; }
voc -O2 SqrtBits.Mod -m >/dev/null && ./SqrtBits < "$C/SqrtBits.vals" > SqrtBits.out &&
  { printf 'MathL.sqrt (issue 47): '; python3 "$C/sqrtcheck.py" "$C/SqrtBits.vals" SqrtBits.out; }
voc -OC SqrtBitsR.Mod -m >/dev/null && ./SqrtBitsR < "$C/SqrtBitsR.vals" > SqrtBitsR.out &&
  { printf 'Math.sqrt (issue 47): '; python3 "$C/sqrtcheckr.py" "$C/SqrtBitsR.vals" SqrtBitsR.out; }
voc -O2 TrigBits.Mod -m >/dev/null && ./TrigBits < "$C/TrigBits.vals" > TrigBits.out &&
  { printf 'sin, cos, tan (issue 48): '; python3 "$C/trigcheck.py" "$C/TrigBits.vals" TrigBits.out; }
echo "outputs in $d"
