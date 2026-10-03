#!/bin/sh
# literals.sh VOCDIR SRCDIR: compile each distinct real literal found in
# the .Mod files under SRCDIR (voc's src/, for the counts in patch 0002)
# with the voc installed in VOCDIR, under -OC, and count the values that
# are not correctly rounded.
[ $# -eq 2 ] || { echo "usage: $0 VOCDIR SRCDIR" >&2; exit 2; }
V=$(cd "$1" && pwd); C=$(cd "$(dirname "$0")" && pwd)
d=$(mktemp -d); python3 "$C/literals.py" extract "$2" > "$d/lits"
cd "$d"
while IFS= read -r l || [ -n "$l" ]; do
  case $l in *[Dd]*) ty=LONGREAL; it=SYSTEM.INT64; w=16;; *) ty=REAL; it=SYSTEM.INT32; w=8;; esac
  rm -rf m; mkdir m
  printf 'MODULE L; IMPORT SYSTEM, Out; VAR x: %s; h: %s;\nBEGIN x := %s; h := SYSTEM.VAL(%s, x); Out.Hex(h, %s); Out.Ln END L.\n' \
    $ty $it "$l" $it $w > m/L.Mod
  r=$(cd m && PATH=$V/bin:$PATH timeout 20 voc -OC L.Mod -m >/dev/null 2>&1 && LD_LIBRARY_PATH=$V/lib ./L || echo ERR)
  echo "$l $r"
done < lits > results
python3 "$C/literals.py" compare results
echo "results in $d/results"
